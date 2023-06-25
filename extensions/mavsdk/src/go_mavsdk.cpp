#include <go_mavsdk.h>
#include <unordered_set>
#include <array>

std::array<std::unordered_set<GoMAVSDK *>, UINT8_MAX+1> _go_mavsdk_sets;

void GoMAVSDK::set_sys_id(int32_t p_sys_id)
{
	if (sys_id <= UINT8_MAX && sys_id >= 0)
		_go_mavsdk_sets[sys_id].erase(this);

	if (p_sys_id <= UINT8_MAX && p_sys_id >= 0)
		_go_mavsdk_sets[p_sys_id].insert(this);

	sys_id = p_sys_id;
}

int32_t GoMAVSDK::get_sys_id() const { return sys_id; };
void GoMAVSDK::set_sys_enable(bool p_sys_enable) { sys_enable = p_sys_enable; };
bool GoMAVSDK::get_sys_enable() const { return sys_enable; };

bool GoMAVSDK::is_system_discovered() const { return server->is_system_discovered(sys_id); }
bool GoMAVSDK::is_system_connected() const { return server->is_system_connected(sys_id); }

GoMAVSDKServer::ShellResult GoMAVSDK::send_shell(const String &command)
{
	if (!sys_enable)
	{
		return GoMAVSDKServer::ShellResult::SHELL_UNKNOWN;
	}
	return server->send_shell(sys_id, command);
}

Dictionary GoMAVSDK::get_param(const String &name)
{
	Dictionary result;
	if (!sys_enable)
	{
		result["status"] = GoMAVSDKServer::ParamResult::PARAM_UNKNOWN;
		result["value"] = 0;
		return result;
	}
	return server->get_param(sys_id, name);
}

GoMAVSDKServer::ParamResult GoMAVSDK::set_param(const String &name, const Variant &value)
{
	if (!sys_enable)
	{
		return GoMAVSDKServer::ParamResult::PARAM_UNKNOWN;
	}
	return server->set_param(sys_id, name, value);
}

Dictionary GoMAVSDK::get_all_params()
{
	if (!sys_enable)
	{
		return Dictionary{};
	}
	return server->get_all_params(sys_id);
}

GoMAVSDKServer::MavlinkPassthroughResult GoMAVSDK::send_mavlink(const PackedByteArray &message)
{
	if (!sys_enable)
	{
		return GoMAVSDKServer::MavlinkPassthroughResult::MAVLINK_PASSTHROUGH_UNKNOWN;
	}

	return server->send_mavlink(sys_id, message);
}

bool GoMAVSDK::add_mavlink_subscription(const int32_t &message_id)
{
	if (!sys_enable)
	{
		return false;
	}
	return server->add_mavlink_subscription(sys_id, message_id);
}

void GoMAVSDK::request_manual_control(GoMAVSDKServer::ManualControlMode mode)
{
	if (!sys_enable)
	{
		return;
	}

	server->request_manual_control(sys_id, mode);
}

GoMAVSDKServer::ManualControlResult GoMAVSDK::send_manual_control(const real_t &x, const real_t &y, const real_t &z, const real_t &r)
{
	if (!sys_enable)
	{
		return GoMAVSDKServer::ManualControlResult::MANUAL_CONTROL_UNKNOWN;
	}

	return server->send_manual_control(sys_id, x, y, z, r);
}

void GoMAVSDK::_on_shell_received(const String &message)
{
	if (sys_enable)
	{
		emit_signal("shell_received", message);
	}
}
void GoMAVSDK::_on_mavlink_received(const PackedByteArray &message)
{
	if (sys_enable)
	{
		emit_signal("mavlink_received", message);
	}
}

void GoMAVSDK::_on_response_manual_control(GoMAVSDKServer::ManualControlResult result)
{
	if (sys_enable)
	{
		emit_signal("response_manual_control", result);
	}
}

void GoMAVSDK::_bind_methods()
{
	ClassDB::bind_method(D_METHOD("set_sys_id", "sys_id"), &GoMAVSDK::set_sys_id);
	ClassDB::bind_method(D_METHOD("get_sys_id"), &GoMAVSDK::get_sys_id);
	ClassDB::bind_method(D_METHOD("set_sys_enable", "sys_enable"), &GoMAVSDK::set_sys_enable);
	ClassDB::bind_method(D_METHOD("get_sys_enable"), &GoMAVSDK::get_sys_enable);

	ADD_PROPERTY(PropertyInfo(Variant::INT, "sys_id", PROPERTY_HINT_RANGE, "-1,255"), "set_sys_id", "get_sys_id");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "sys_enable"), "set_sys_enable", "get_sys_enable");
	ADD_SIGNAL(MethodInfo("shell_received", PropertyInfo(Variant::STRING, "shell")));
	ADD_SIGNAL(MethodInfo("mavlink_received", PropertyInfo(Variant::PACKED_BYTE_ARRAY, "message")));
	ADD_SIGNAL(MethodInfo("response_manual_control", PropertyInfo(Variant::INT, "result")));

	ClassDB::bind_method(D_METHOD("is_system_discovered"), &GoMAVSDK::is_system_discovered);
	ClassDB::bind_method(D_METHOD("is_system_connected"), &GoMAVSDK::is_system_connected);
	ClassDB::bind_method(D_METHOD("send_shell", "command"), &GoMAVSDK::send_shell);
	ClassDB::bind_method(D_METHOD("get_param", "name"), &GoMAVSDK::get_param);
	ClassDB::bind_method(D_METHOD("set_param", "name", "value"), &GoMAVSDK::set_param);
	ClassDB::bind_method(D_METHOD("get_all_params"), &GoMAVSDK::get_all_params);
	ClassDB::bind_method(D_METHOD("send_mavlink", "message"), &GoMAVSDK::send_mavlink);
	ClassDB::bind_method(D_METHOD("add_mavlink_subscription", "message_id"), &GoMAVSDK::add_mavlink_subscription);

	ClassDB::bind_method(D_METHOD("request_manual_control", "mode"), &GoMAVSDK::request_manual_control);
	ClassDB::bind_method(D_METHOD("send_manual_control", "x", "y", "z", "r"), &GoMAVSDK::send_manual_control);
}
