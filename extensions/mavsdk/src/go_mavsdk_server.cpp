#include <go_mavsdk_server.h>
#include <go_mavsdk.h>
#include <unordered_set>
#include <iostream>

using namespace std::this_thread;
using namespace std::chrono;

GoMAVSDKServer *GoMAVSDKServer::singleton = nullptr;
std::unique_ptr<std::thread> GoMAVSDKServer::_discovery_thread;
std::atomic<bool> GoMAVSDKServer::_request_discovery_stop{true};
std::map<int32_t, GoMAVSDKServer::APIs> GoMAVSDKServer::_apis;
int32_t GoMAVSDKServer::_standalones{0};
std::shared_ptr<mavsdk::Mavsdk> GoMAVSDKServer::_mavsdk;

static bool initialized{false};
void GoMAVSDKServer::initialize(bool force)
{
	if (initialized)
	{
		if (force)
		{
			_finalize();
		}
		else
		{
			return;
		}
	}

	_standalones = 0;
	_mavsdk = std::make_shared<mavsdk::Mavsdk>();
	mavsdk::Mavsdk::Configuration config{mavsdk::Mavsdk::Configuration::UsageType::GroundStation};
	config.set_system_id(system_id);
	_mavsdk->set_configuration(config);
	initialized = true;
}

void GoMAVSDKServer::_finalize()
{
	if (initialized)
	{
		stop_discovery();

		for (auto &api : _apis)
		{
			api.second.system.reset();
			api.second.shell.reset();
			api.second.param.reset();
			api.second.mavlink_passthrough.reset();
		}

		_apis.clear();
		_mavsdk.reset();

		initialized = false;
	}
}

void GoMAVSDKServer::set_system_id(int32_t sys_id)
{
	if(sys_id > 255 || sys_id < 0) {
		WARN_PRINT("Tried to set_system_id of wrong range");
		return;
	}

	this->system_id = sys_id;

	if (_mavsdk)
	{
		mavsdk::Mavsdk::Configuration config{mavsdk::Mavsdk::Configuration::UsageType::GroundStation};
		config.set_system_id(system_id);
		_mavsdk->set_configuration(config);
	}
}

void GoMAVSDKServer::_on_shell_received(const int32_t &sys_id, const String message)
{
	emit_signal("shell_received", sys_id, message);
	extern std::unordered_set<GoMAVSDK *> _go_mavsdk_set;
	for (auto &iter : _go_mavsdk_set)
	{
		iter->_on_shell_received(sys_id, message);
	}
}

void GoMAVSDKServer::_on_mavlink_received(const int32_t &sys_id, const PackedByteArray &message)
{
	emit_signal("mavlink_received", sys_id, message);
	extern std::unordered_set<GoMAVSDK *> _go_mavsdk_set;
	for (auto &iter : _go_mavsdk_set)
	{
		iter->_on_mavlink_received(sys_id, message);
	}
}

GoMAVSDKServer::ConnectionResult GoMAVSDKServer::add_connection(String address, ForwardOption forwarding)
{
	return (ConnectionResult)_mavsdk->add_any_connection(address.utf8().get_data(), (mavsdk::ForwardingOption)forwarding);
}

GoMAVSDKServer::ConnectionResult GoMAVSDKServer::setup_udp_remote(String remote_ip, int32_t remote_port, ForwardOption forwarding)
{
	return (ConnectionResult)_mavsdk->setup_udp_remote(remote_ip.utf8().get_data(), remote_port, (mavsdk::ForwardingOption)forwarding);
}

void GoMAVSDKServer::start_discovery()
{
	_request_discovery_stop.store(false);
	_discovery_thread = std::make_unique<std::thread>(
		[this]
		{
			_mavsdk->subscribe_on_new_system(
				[this]()
				{
					if (_mavsdk->systems().size() > (_apis.size() + _standalones))
					{
						for (auto system : _mavsdk->systems())
						{
							const int32_t sys_id = system->get_system_id();
							if (system->has_autopilot())
							{
								if (_apis.count(sys_id) == 0)
								{
									APIs api;
									api.system = system;
									api.shell = std::make_shared<mavsdk::Shell>(system);
									api.param = std::make_shared<mavsdk::Param>(system);
									api.mavlink_passthrough = std::make_shared<mavsdk::MavlinkPassthrough>(system);
									api.shell->subscribe_receive([this, sys_id](const std::string output)
																 { _on_shell_received(sys_id, output.data()); });
									_THREAD_SAFE_LOCK_
									_apis.insert({sys_id, api});
									_THREAD_SAFE_UNLOCK_
									emit_signal("system_discovered", sys_id);
								}
							}
						}
						_standalones = _mavsdk->systems().size() - _apis.size();
					}
				});

			while (!_request_discovery_stop.load())
			{
				sleep_for(duration<double>(1.0));
			}
		});
}

void GoMAVSDKServer::stop_discovery()
{
	if (_request_discovery_stop.load() == false)
	{
		_request_discovery_stop.store(true);
		_discovery_thread->join();
		_discovery_thread.reset();
	}
}

TypedArray<int32_t> GoMAVSDKServer::get_discovered() const
{
	_THREAD_SAFE_METHOD_
	TypedArray<int32_t> discovered;
	for (const auto &api : _apis)
		discovered.push_back(api.first);
	return discovered;
}

TypedArray<int32_t> GoMAVSDKServer::get_connected() const
{
	_THREAD_SAFE_METHOD_
	TypedArray<int32_t> connected;
	for (const auto &api : _apis)
	{
		if (api.second.system->is_connected())
		{
			connected.push_back(api.first);
		}
	}
	return connected;
}

bool GoMAVSDKServer::is_system_discovered(int32_t sys_id) const
{
	_THREAD_SAFE_METHOD_
	return (_apis.count(sys_id) != 0);
}

bool GoMAVSDKServer::is_system_connected(int32_t sys_id) const
{
	_THREAD_SAFE_METHOD_
	if (is_system_discovered(sys_id))
	{
		return _apis[sys_id].system->is_connected();
	}
	return false;
}

GoMAVSDKServer::ShellResult GoMAVSDKServer::send_shell(int32_t sys_id, String command)
{
	_THREAD_SAFE_METHOD_
	if (is_system_discovered(sys_id))
	{
		return (ShellResult)_apis[sys_id].shell->send(command.utf8().get_data());
	}

	return ShellResult::SHELL_NOSYSTEM;
}

Dictionary GoMAVSDKServer::get_param(int32_t sys_id, String name)
{
	_THREAD_SAFE_METHOD_
	Dictionary result;
	if (is_system_discovered(sys_id))
	{
		const std::pair<mavsdk::Param::Result, int32_t> int_result = _apis[sys_id].param->get_param_int(name.utf8().get_data());
		if (int_result.first == mavsdk::Param::Result::WrongType)
		{
			const std::pair<mavsdk::Param::Result, float> float_result = _apis[sys_id].param->get_param_float(name.utf8().get_data());
			result["status"] = (ParamResult)float_result.first;
			result["value"] = float_result.second;
		}
		else
		{
			result["status"] = (ParamResult)int_result.first;
			result["value"] = int_result.second;
		}
		return result;
	}

	result["status"] = ParamResult::PARAM_NOSYSTEM;
	result["value"] = 0;
	return result;
}

GoMAVSDKServer::ParamResult GoMAVSDKServer::set_param(int32_t sys_id, String name, Variant value)
{
	_THREAD_SAFE_METHOD_
	if (is_system_discovered(sys_id))
	{
		switch (value.get_type())
		{
		case Variant::FLOAT:
			return (ParamResult)_apis[sys_id].param->set_param_float(name.utf8().get_data(), value.operator float());
		case Variant::INT:
			return (ParamResult)_apis[sys_id].param->set_param_int(name.utf8().get_data(), value.operator int());
		default:
			return ParamResult::PARAM_WRONGTYPE;
		}
	}

	return ParamResult::PARAM_NOSYSTEM;
}

Dictionary GoMAVSDKServer::get_all_params(int32_t sys_id)
{
	_THREAD_SAFE_METHOD_
	Dictionary result;
	Array names;
	Array values;
	if (is_system_discovered(sys_id))
	{
		const mavsdk::Param::AllParams params = _apis[sys_id].param->get_all_params();
		result["status"] = ParamResult::PARAM_SUCCESS;

		for (const auto &param : params.int_params)
		{
			names.push_back(String(param.name.c_str()));
			values.push_back(param.value);
		}

		for (const auto &param : params.float_params)
		{
			names.push_back(String(param.name.c_str()));
			values.push_back(param.value);
		}
	}
	else
	{
		result["status"] = ParamResult::PARAM_NOSYSTEM;
	}

	result["names"] = names;
	result["values"] = values;
	return result;
}

void GoMAVSDKServer::_mavlink_message_callback(const int32_t &sys_id, const mavlink_message_t &mavlink_message)
{
	PackedByteArray message;
	message.resize(mavlink_msg_get_send_buffer_length(&mavlink_message));
	mavlink_msg_to_send_buffer(message.ptrw(), &mavlink_message);
	_on_mavlink_received(sys_id, message);
}

bool GoMAVSDKServer::add_mavlink_subscription(int32_t sys_id, int32_t message_id)
{
	if (is_system_discovered(sys_id))
	{
		_apis[sys_id].mavlink_passthrough->subscribe_message_async(message_id, std::bind(&GoMAVSDKServer::_mavlink_message_callback, this, sys_id, std::placeholders::_1));
		return true;
	}

	return false;
}

static inline void receive_buffer_to_mavlink_msg(const uint8_t *buf, mavlink_message_t *msg)
{
	if (buf[0] == MAVLINK_STX_MAVLINK1)
	{
		msg->magic = buf[0];
		msg->len = buf[1];
		msg->seq = buf[2];
		msg->sysid = buf[3];
		msg->compid = buf[4];
		msg->msgid = buf[5];
		memcpy(((char *)(&((msg)->payload64[0]))), &buf[6], msg->len);
		const uint8_t *ck = buf + MAVLINK_CORE_HEADER_MAVLINK1_LEN + 1 + (uint16_t)msg->len;
		msg->checksum = (uint16_t(ck[1]) << 8) | (uint16_t(ck[0]));
	}
	else
	{
		msg->magic = buf[0];
		msg->len = buf[1];
		msg->incompat_flags = buf[2];
		msg->compat_flags = buf[3];
		msg->seq = buf[4];
		msg->sysid = buf[5];
		msg->compid = buf[6];
		msg->msgid = ((uint32_t)buf[7]) | (((uint32_t)buf[8]) << 8) | (((uint32_t)buf[9]) << 16);
		memcpy(((char *)(&((msg)->payload64[0]))), &buf[10], msg->len);
		const uint8_t *ck = buf + MAVLINK_CORE_HEADER_LEN + 1 + (uint16_t)msg->len;
		msg->checksum = (uint16_t(ck[1]) << 8) | (uint16_t(ck[0]));
		const uint8_t signature_len = (msg->incompat_flags & MAVLINK_IFLAG_SIGNED) ? MAVLINK_SIGNATURE_BLOCK_LEN : 0;
		if (signature_len > 0)
		{
			memcpy(msg->signature, &ck[2], signature_len);
		}
	}
}

GoMAVSDKServer::MavlinkPassthroughResult GoMAVSDKServer::send_mavlink(int32_t sys_id, const PackedByteArray &message)
{
	_THREAD_SAFE_METHOD_
	if (is_system_discovered(sys_id))
	{
		mavlink_message_t mavlink_message;
		receive_buffer_to_mavlink_msg(message.ptr(), &mavlink_message);
		return (MavlinkPassthroughResult)_apis[sys_id].mavlink_passthrough->send_message(mavlink_message);
	}

	return MavlinkPassthroughResult::MAVLINK_PASSTHROUGH_COMMANDNOSYSTEM;
}

void GoMAVSDKServer::_bind_methods()
{
	ADD_SIGNAL(MethodInfo("system_discovered", PropertyInfo(Variant::INT, "sys_id")));													  // Verified
	ADD_SIGNAL(MethodInfo("shell_received", PropertyInfo(Variant::INT, "sys_id"), PropertyInfo(Variant::STRING, "shell")));				  // Verified
	ADD_SIGNAL(MethodInfo("mavlink_received", PropertyInfo(Variant::INT, "sys_id"), PropertyInfo(Variant::PACKED_BYTE_ARRAY, "message"))); // Verified
	ClassDB::bind_method(D_METHOD("initialize", "force"), &GoMAVSDKServer::initialize, DEFVAL(0));											  // Verified
	ClassDB::bind_method(D_METHOD("set_system_id", "sys_id"), &GoMAVSDKServer::set_system_id);												  // Verified
	ClassDB::bind_method(D_METHOD("get_system_id"), &GoMAVSDKServer::get_system_id);														  // Verified
	ClassDB::bind_method(D_METHOD("add_connection", "address", "forwarding"), &GoMAVSDKServer::add_connection, DEFVAL(0));					  // Verified
	ClassDB::bind_method(D_METHOD("setup_udp_remote", "remote_ip", "remote_port", "forwarding"), &GoMAVSDKServer::setup_udp_remote, DEFVAL(0));
	ClassDB::bind_method(D_METHOD("start_discovery"), &GoMAVSDKServer::start_discovery);
	ClassDB::bind_method(D_METHOD("stop_discovery"), &GoMAVSDKServer::stop_discovery);
	ClassDB::bind_method(D_METHOD("get_discovered"), &GoMAVSDKServer::get_discovered);						 // Verified
	ClassDB::bind_method(D_METHOD("get_connected"), &GoMAVSDKServer::get_connected);						 // Verified
	ClassDB::bind_method(D_METHOD("is_system_discovered", "sys_id"), &GoMAVSDKServer::is_system_discovered); // Verified
	ClassDB::bind_method(D_METHOD("is_system_connected", "sys_id"), &GoMAVSDKServer::is_system_connected);	 // Verified
	ClassDB::bind_method(D_METHOD("send_shell", "sys_id", "command"), &GoMAVSDKServer::send_shell);			 // Verified
	ClassDB::bind_method(D_METHOD("get_param", "sys_id", "name"), &GoMAVSDKServer::get_param);				 // Verified
	ClassDB::bind_method(D_METHOD("set_param", "sys_id", "name", "value"), &GoMAVSDKServer::set_param);		 // Verified
	ClassDB::bind_method(D_METHOD("get_all_params", "sys_id"), &GoMAVSDKServer::get_all_params);			 // Verified
	ClassDB::bind_method(D_METHOD("send_mavlink", "sys_id", "message"), &GoMAVSDKServer::send_mavlink);
	ClassDB::bind_method(D_METHOD("add_mavlink_subscription", "sys_id", "message_id"), &GoMAVSDKServer::add_mavlink_subscription); // Verified partially

	BIND_ENUM_CONSTANT(FORWARD_OFF);
	BIND_ENUM_CONSTANT(FORWARD_ON);

	BIND_ENUM_CONSTANT(CONNECTION_SUCCESS);
	BIND_ENUM_CONSTANT(CONNECTION_TIMEOUT);
	BIND_ENUM_CONSTANT(CONNECTION_SOCKETERROR);
	BIND_ENUM_CONSTANT(CONNECTION_BINDERROR);
	BIND_ENUM_CONSTANT(CONNECTION_SOCKETCONNECTIONERROR);
	BIND_ENUM_CONSTANT(CONNECTION_CONNECTIONERROR);
	BIND_ENUM_CONSTANT(CONNECTION_NOTIMPLEMENTED);
	BIND_ENUM_CONSTANT(CONNECTION_SYSTEMNOTCONNECTED);
	BIND_ENUM_CONSTANT(CONNECTION_SYSTEMBUSY);
	BIND_ENUM_CONSTANT(CONNECTION_COMMANDDENIED);
	BIND_ENUM_CONSTANT(CONNECTION_DESTINATIONIPUNKNOWN);
	BIND_ENUM_CONSTANT(CONNECTION_CONNECTIONSEXHAUSTED);
	BIND_ENUM_CONSTANT(CONNECTION_CONNECTIONURLINVALID);
	BIND_ENUM_CONSTANT(CONNECTION_BAUDRATEUNKNOWN);

	BIND_ENUM_CONSTANT(SHELL_UNKNOWN);
	BIND_ENUM_CONSTANT(SHELL_SUCCESS);
	BIND_ENUM_CONSTANT(SHELL_NOSYSTEM);
	BIND_ENUM_CONSTANT(SHELL_CONNECTIONERROR);
	BIND_ENUM_CONSTANT(SHELL_NORESPONSE);
	BIND_ENUM_CONSTANT(SHELL_BUSY);

	BIND_ENUM_CONSTANT(PARAM_UNKNOWN);
	BIND_ENUM_CONSTANT(PARAM_SUCCESS);
	BIND_ENUM_CONSTANT(PARAM_TIMEOUT);
	BIND_ENUM_CONSTANT(PARAM_CONNECTIONERROR);
	BIND_ENUM_CONSTANT(PARAM_WRONGTYPE);
	BIND_ENUM_CONSTANT(PARAM_PARAMNAMETOOLONG);
	BIND_ENUM_CONSTANT(PARAM_NOSYSTEM);
	BIND_ENUM_CONSTANT(PARAM_PARAMVALUETOOLONG);

	BIND_ENUM_CONSTANT(MAVLINK_PASSTHROUGH_UNKNOWN);
	BIND_ENUM_CONSTANT(MAVLINK_PASSTHROUGH_SUCCESS);
	BIND_ENUM_CONSTANT(MAVLINK_PASSTHROUGH_CONNECTIONERROR);
	BIND_ENUM_CONSTANT(MAVLINK_PASSTHROUGH_COMMANDNOSYSTEM);
	BIND_ENUM_CONSTANT(MAVLINK_PASSTHROUGH_COMMANDBUSY);
	BIND_ENUM_CONSTANT(MAVLINK_PASSTHROUGH_COMMANDDENIED);
	BIND_ENUM_CONSTANT(MAVLINK_PASSTHROUGH_COMMANDUNSUPPORTED);
	BIND_ENUM_CONSTANT(MAVLINK_PASSTHROUGH_COMMANDTIMEOUT);
}