#pragma once

#include "go_mavsdk_server.h"

class GoMAVSDK : public Node {
	GDCLASS(GoMAVSDK, Node)

protected:
	static void _bind_methods();

public:
	GoMAVSDK();
	~GoMAVSDK();

	void set_sys_id(int32_t p_sys_id);
	int32_t get_sys_id() const;
	void set_sys_enable(bool p_sys_enable);
	bool get_sys_enable() const;
	bool is_system_discovered() const;
	bool is_system_connected() const;
	GoMAVSDKServer::ShellResult send_shell(const String &command);
	Dictionary get_param(const String &name);
	GoMAVSDKServer::ParamResult set_param(const String &name, const Variant &value);
	Dictionary get_all_params();
	GoMAVSDKServer::MavlinkPassthroughResult send_mavlink(const PackedByteArray &message);
	bool add_mavlink_subscription(const int32_t &message_id);

	void _on_shell_received(const int32_t &p_sys_id, const String &message);
	void _on_mavlink_received(const int32_t &p_sys_id, const PackedByteArray &message);

private:
	GoMAVSDKServer *server{ GoMAVSDKServer::get_singleton() };
	bool sys_enable{ true };
	int32_t sys_id{ -1 };
};
