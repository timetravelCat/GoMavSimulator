#include <go_mavsdk.h>
#include <unordered_set>

std::unordered_set<GoMAVSDK*> _go_mavsdk_set;

GoMAVSDK::GoMAVSDK(){
    _go_mavsdk_set.insert(this);
};

GoMAVSDK::~GoMAVSDK(){
    _go_mavsdk_set.erase(this);
};

void GoMAVSDK::set_sys_id(int32_t p_sys_id) { sys_id = p_sys_id; }
int32_t GoMAVSDK::get_sys_id() const { return sys_id; };
void GoMAVSDK::set_sys_enable(bool p_sys_enable) { sys_enable = p_sys_enable; };
bool GoMAVSDK::get_sys_enable() const { return sys_enable; };

bool GoMAVSDK::is_system_discovered() const { return server->is_system_discovered(sys_id); }
bool GoMAVSDK::is_system_connected() const { return server->is_system_connected(sys_id); }

GoMAVSDKServer::ShellResult GoMAVSDK::send_shell(const String &command) {
	if (!sys_enable) {
		return GoMAVSDKServer::ShellResult::SHELL_UNKNOWN;
	}
	return server->send_shell(sys_id, command);
}

Dictionary GoMAVSDK::get_param(const String &name) {
	Dictionary result;
	if (!sys_enable) {
		result["status"] = GoMAVSDKServer::ParamResult::PARAM_UNKNOWN;
		result["value"] = 0;
		return result;
	}
	return server->get_param(sys_id, name);
}

GoMAVSDKServer::ParamResult GoMAVSDK::set_param(const String &name, const Variant &value) {
	if (!sys_enable) {
		return GoMAVSDKServer::ParamResult::PARAM_UNKNOWN;
	}
	return server->set_param(sys_id, name, value);
}

Dictionary GoMAVSDK::get_all_params() {
	if (!sys_enable) {
		return Dictionary{};
	}
	return server->get_all_params(sys_id);
}

GoMAVSDKServer::MavlinkPassthroughResult GoMAVSDK::send_mavlink(const PackedByteArray &message) {
	if (!sys_enable) {
		return GoMAVSDKServer::MavlinkPassthroughResult::MAVLINK_PASSTHROUGH_UNKNOWN;
	}

	return server->send_mavlink(sys_id, message);
}

bool GoMAVSDK::add_mavlink_subscription(const int32_t &message_id) {
	if (!sys_enable) {
		return false;
	}
	return server->add_mavlink_subscription(sys_id, message_id);
}

void GoMAVSDK::_on_shell_received(const int32_t &p_sys_id, const String &message) {
	if (sys_enable && (sys_id == p_sys_id)) {
		emit_signal("on_shell_received", message);
	}
}
void GoMAVSDK::_on_mavlink_received(const int32_t &p_sys_id, const PackedByteArray &message) {
	if (sys_enable && (sys_id == p_sys_id)) {
		emit_signal("on_mavlink_received", message);
	}
}

void GoMAVSDK::_bind_methods() {
	ClassDB::bind_method(D_METHOD("set_sys_id", "sys_id"), &GoMAVSDK::set_sys_id);
	ClassDB::bind_method(D_METHOD("get_sys_id"), &GoMAVSDK::get_sys_id);
	ClassDB::bind_method(D_METHOD("set_sys_enable", "sys_enable"), &GoMAVSDK::set_sys_enable);
	ClassDB::bind_method(D_METHOD("get_sys_enable"), &GoMAVSDK::get_sys_enable);

	ADD_PROPERTY(PropertyInfo(Variant::INT, "sys_id"), "set_sys_id", "get_sys_id");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "sys_enable"), "set_sys_enable", "get_sys_enable");
	ADD_SIGNAL(MethodInfo("on_shell_received", PropertyInfo(Variant::STRING, "shell")));
	ADD_SIGNAL(MethodInfo("on_mavlink_received", PropertyInfo(Variant::PACKED_BYTE_ARRAY, "message")));

	ClassDB::bind_method(D_METHOD("is_system_discovered"), &GoMAVSDK::is_system_discovered);
	ClassDB::bind_method(D_METHOD("is_system_connected"), &GoMAVSDK::is_system_connected);
	ClassDB::bind_method(D_METHOD("send_shell", "command"), &GoMAVSDK::send_shell);
	ClassDB::bind_method(D_METHOD("get_param", "name"), &GoMAVSDK::get_param);
	ClassDB::bind_method(D_METHOD("set_param", "name", "value"), &GoMAVSDK::set_param);
	ClassDB::bind_method(D_METHOD("get_all_params"), &GoMAVSDK::get_all_params);
	ClassDB::bind_method(D_METHOD("send_mavlink", "message"), &GoMAVSDK::send_mavlink);
	ClassDB::bind_method(D_METHOD("add_mavlink_subscription", "message_id"), &GoMAVSDK::add_mavlink_subscription);
}
