#pragma once

#include "go_mavsdk_server.h"

class GoMAVSDK : public Node {
	GDCLASS(GoMAVSDK, Node)

protected:
	static void _bind_methods();

public:
	GoMAVSDK() {};
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
	void request_manual_control(GoMAVSDKServer::ManualControlMode mode);
	GoMAVSDKServer::ManualControlResult send_manual_control(const real_t& x, const real_t& y, const real_t& z, const real_t& r);
	void request_arm();
	void request_disarm();
	void request_takeoff();
	void request_land();
	void request_reboot();
	void request_shutdown();
	void request_terminate();
	void request_kill();
	void request_return_to_launch();
	void request_hold();

	void _on_shell_received(const String &message);
	void _on_mavlink_received(const mavlink_message_t &mavlink_message, const PackedByteArray &byte_message);
	void _on_response_manual_control(GoMAVSDKServer::ManualControlResult result);
	void _on_response_action(GoMAVSDKServer::ActionResult result);
	void _on_armed_received(bool armed);
	void _on_flightmode_received(GoMAVSDKServer::FlightMode flight_mode);

	enum OdometrySource
	{
		ODOMETRY_GROUND_TRUTH,
		ODOMETRY_ESTIMATION
	};

	OdometrySource odometry_source{OdometrySource::ODOMETRY_GROUND_TRUTH};
	void set_odometry_source(OdometrySource p_odometry_source) {odometry_source = p_odometry_source;}
	OdometrySource get_odometry_source() {return odometry_source;}

	void set_ned_to_eus(bool p_ned_to_eus) { ned_to_eus = p_ned_to_eus; };
	bool get_ned_to_eus() { return ned_to_eus; };
	bool ned_to_eus{ true };

	Quaternion get_orientation() {return orientation;}
	void set_orientation(Quaternion p_orientation) {orientation = p_orientation;}
	Quaternion orientation;

	Vector3 get_position(){return position;}
	void set_position(Vector3 p_position) {position = p_position;}
	Vector3 position;

private:
	bool is_vehicle_standby{false};
	bool is_reference_valid{false};
	int32_t reference_latitude;
	int32_t reference_longitude;
	int32_t reference_altitude;

	GoMAVSDKServer *server{ GoMAVSDKServer::get_singleton() };
	bool sys_enable{ true };
	int32_t sys_id{ -1 };

	void parse_odometry_subscription(const mavlink_message_t &mavlink_message);
};

VARIANT_ENUM_CAST(GoMAVSDK::OdometrySource);