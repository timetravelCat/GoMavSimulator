#pragma once

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/variant/variant.hpp>
#include <godot_cpp/godot.hpp>
#include <godot_cpp/core/mutex_lock.hpp>

#include <atomic>
#include <map>
#include <memory>
#include <thread>

#include <mavsdk/mavsdk.h>
#include <mavsdk/plugins/mavlink_passthrough/mavlink_passthrough.h>
#include <mavsdk/plugins/param/param.h>
#include <mavsdk/plugins/shell/shell.h>
#include <mavsdk/system.h>

using namespace godot;

class GoMAVSDKServer : public Object {
	GDCLASS(GoMAVSDKServer, Object)
	_THREAD_SAFE_CLASS_

public:
	enum ForwardOption {
		FORWARD_OFF = (int)mavsdk::ForwardingOption::ForwardingOff,
		FORWARD_ON = (int)mavsdk::ForwardingOption::ForwardingOn
	};

	enum ConnectionResult {
		CONNECTION_SUCCESS = (int)mavsdk::ConnectionResult::Success,
		CONNECTION_TIMEOUT = (int)mavsdk::ConnectionResult::Timeout,
		CONNECTION_SOCKETERROR = (int)mavsdk::ConnectionResult::SocketError,
		CONNECTION_BINDERROR = (int)mavsdk::ConnectionResult::BindError,
		CONNECTION_SOCKETCONNECTIONERROR = (int)mavsdk::ConnectionResult::SocketConnectionError,
		CONNECTION_CONNECTIONERROR = (int)mavsdk::ConnectionResult::ConnectionError,
		CONNECTION_NOTIMPLEMENTED = (int)mavsdk::ConnectionResult::NotImplemented,
		CONNECTION_SYSTEMNOTCONNECTED = (int)mavsdk::ConnectionResult::SystemNotConnected,
		CONNECTION_SYSTEMBUSY = (int)mavsdk::ConnectionResult::SystemBusy,
		CONNECTION_COMMANDDENIED = (int)mavsdk::ConnectionResult::CommandDenied,
		CONNECTION_DESTINATIONIPUNKNOWN = (int)mavsdk::ConnectionResult::DestinationIpUnknown,
		CONNECTION_CONNECTIONSEXHAUSTED = (int)mavsdk::ConnectionResult::ConnectionsExhausted,
		CONNECTION_CONNECTIONURLINVALID = (int)mavsdk::ConnectionResult::ConnectionUrlInvalid,
		CONNECTION_BAUDRATEUNKNOWN = (int)mavsdk::ConnectionResult::BaudrateUnknown
	};

	enum ShellResult {
		SHELL_UNKNOWN = (int)mavsdk::Shell::Result::Unknown,
		SHELL_SUCCESS = (int)mavsdk::Shell::Result::Success,
		SHELL_NOSYSTEM = (int)mavsdk::Shell::Result::NoSystem,
		SHELL_CONNECTIONERROR = (int)mavsdk::Shell::Result::ConnectionError,
		SHELL_NORESPONSE = (int)mavsdk::Shell::Result::NoResponse,
		SHELL_BUSY = (int)mavsdk::Shell::Result::Busy
	};

	enum ParamResult {
		PARAM_UNKNOWN = (int)mavsdk::Param::Result::Unknown,
		PARAM_SUCCESS = (int)mavsdk::Param::Result::Success,
		PARAM_TIMEOUT = (int)mavsdk::Param::Result::Timeout,
		PARAM_CONNECTIONERROR = (int)mavsdk::Param::Result::ConnectionError,
		PARAM_WRONGTYPE = (int)mavsdk::Param::Result::WrongType,
		PARAM_PARAMNAMETOOLONG = (int)mavsdk::Param::Result::ParamNameTooLong,
		PARAM_NOSYSTEM = (int)mavsdk::Param::Result::NoSystem,
		PARAM_PARAMVALUETOOLONG = (int)mavsdk::Param::Result::ParamValueTooLong
	};

	enum MavlinkPassthroughResult {
		MAVLINK_PASSTHROUGH_UNKNOWN = (int)mavsdk::MavlinkPassthrough::Result::Unknown,
		MAVLINK_PASSTHROUGH_SUCCESS = (int)mavsdk::MavlinkPassthrough::Result::Success,
		MAVLINK_PASSTHROUGH_CONNECTIONERROR = (int)mavsdk::MavlinkPassthrough::Result::ConnectionError,
		MAVLINK_PASSTHROUGH_COMMANDNOSYSTEM = (int)mavsdk::MavlinkPassthrough::Result::CommandNoSystem,
		MAVLINK_PASSTHROUGH_COMMANDBUSY = (int)mavsdk::MavlinkPassthrough::Result::CommandBusy,
		MAVLINK_PASSTHROUGH_COMMANDDENIED = (int)mavsdk::MavlinkPassthrough::Result::CommandDenied,
		MAVLINK_PASSTHROUGH_COMMANDUNSUPPORTED = (int)mavsdk::MavlinkPassthrough::Result::CommandUnsupported,
		MAVLINK_PASSTHROUGH_COMMANDTIMEOUT = (int)mavsdk::MavlinkPassthrough::Result::CommandTimeout
	};

	struct APIs {
		std::shared_ptr<mavsdk::System> system;
		std::shared_ptr<mavsdk::Shell> shell;
		std::shared_ptr<mavsdk::Param> param;
		std::shared_ptr<mavsdk::MavlinkPassthrough> mavlink_passthrough;
	};

	static GoMAVSDKServer *get_singleton() {
		return singleton;
	}

private:
	static GoMAVSDKServer *singleton;
	static std::unique_ptr<std::thread> _discovery_thread;
	static std::atomic<bool> _request_discovery_stop;
	static std::map<int32_t, APIs> _apis;
	static int32_t _standalones;
	static std::shared_ptr<mavsdk::Mavsdk> _mavsdk;

	void _mavlink_message_callback(const int32_t &sys_id, const mavlink_message_t &mavlink_message);

	void _on_shell_received(const int32_t& sys_id, const String message);
	void _on_mavlink_received(const int32_t& sys_id, const PackedByteArray& message);

protected:
	static void _bind_methods();

public:
	void initialize(bool force = false);
	void _finalize();

	ConnectionResult add_connection(String address, ForwardOption forwarding = ForwardOption::FORWARD_OFF);
	ConnectionResult setup_udp_remote(String remote_ip, int32_t remote_port, ForwardOption forwarding = ForwardOption::FORWARD_OFF);
	void start_discovery();
	void stop_discovery();

	TypedArray<int32_t> get_discovered() const;
	TypedArray<int32_t> get_connected() const;
	bool is_system_discovered(int32_t sys_id) const;
	bool is_system_connected(int32_t sys_id) const;

	ShellResult send_shell(int32_t sys_id, String command);
	Dictionary get_param(int32_t sys_id, String name);
	ParamResult set_param(int32_t sys_id, String name, Variant value);
	Dictionary get_all_params(int32_t sys_id);

	bool add_mavlink_subscription(int32_t sys_id, int32_t message_id);
	MavlinkPassthroughResult send_mavlink(int32_t sys_id, const PackedByteArray &message);

	GoMAVSDKServer() {
		singleton = this;
		initialize();
	};
	~GoMAVSDKServer() {
		_finalize();
		singleton = nullptr;
	};
};

VARIANT_ENUM_CAST(GoMAVSDKServer::ForwardOption);
VARIANT_ENUM_CAST(GoMAVSDKServer::ConnectionResult);
VARIANT_ENUM_CAST(GoMAVSDKServer::ShellResult);
VARIANT_ENUM_CAST(GoMAVSDKServer::ParamResult);
VARIANT_ENUM_CAST(GoMAVSDKServer::MavlinkPassthroughResult);