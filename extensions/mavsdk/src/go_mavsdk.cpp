#include <go_mavsdk.h>
#include <unordered_set>
#include <array>
#include <ned2eus.h>

std::array<std::unordered_set<GoMAVSDK *>, UINT8_MAX + 1> _go_mavsdk_sets;

GoMAVSDK::~GoMAVSDK()
{
	if (sys_id <= UINT8_MAX && sys_id >= 0)
		_go_mavsdk_sets[sys_id].erase(this);
}

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

void GoMAVSDK::request_arm()
{
	if (!sys_enable)
	{
		return;
	}
	server->request_arm(sys_id);
}

void GoMAVSDK::request_disarm()
{
	if (!sys_enable)
	{
		return;
	}
	server->request_disarm(sys_id);
}

void GoMAVSDK::request_takeoff()
{
	if (!sys_enable)
	{
		return;
	}
	server->request_takeoff(sys_id);
}

void GoMAVSDK::request_land()
{
	if (!sys_enable)
	{
		return;
	}
	server->request_land(sys_id);
}

void GoMAVSDK::request_reboot()
{
	if (!sys_enable)
	{
		return;
	}
	server->request_reboot(sys_id);
}

void GoMAVSDK::request_shutdown()
{
	if (!sys_enable)
	{
		return;
	}
	server->request_shutdown(sys_id);
}

void GoMAVSDK::request_terminate()
{
	if (!sys_enable)
	{
		return;
	}
	server->request_terminate(sys_id);
}

void GoMAVSDK::request_kill()
{
	if (!sys_enable)
	{
		return;
	}
	server->request_kill(sys_id);
}

void GoMAVSDK::request_return_to_launch()
{
	if (!sys_enable)
	{
		return;
	}
	server->request_return_to_launch(sys_id);
}

void GoMAVSDK::request_hold()
{
	if (!sys_enable)
	{
		return;
	}
	server->request_hold(sys_id);
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
		call_deferred("emit_signal", "shell_received", message);
	}
}
void GoMAVSDK::_on_mavlink_received(const mavlink_message_t &mavlink_message, const PackedByteArray &byte_message)
{
	if (sys_enable)
	{
		call_deferred("emit_signal", "mavlink_received", byte_message);
		parse_odometry_subscription(mavlink_message);
	}
}

void GoMAVSDK::parse_odometry_subscription(const mavlink_message_t &mavlink_message)
{
	switch (odometry_source)
	{
	case OdometrySource::ODOMETRY_GROUND_TRUTH:
	{
		switch (mavlink_message.msgid)
		{
		case MAVLINK_MSG_ID_HEARTBEAT:
		{
			mavlink_heartbeat_t heartbeat;
			mavlink_msg_heartbeat_decode(&mavlink_message, &heartbeat);

			is_vehicle_standby = false;
			if (heartbeat.system_status == MAV_STATE_STANDBY)
				is_vehicle_standby = true;
		}
		break;

		case MAVLINK_MSG_ID_HIL_STATE_QUATERNION:
		{
			mavlink_hil_state_quaternion_t hil_state_quaternion;
			mavlink_msg_hil_state_quaternion_decode(&mavlink_message, &hil_state_quaternion);

			if (is_vehicle_standby && !is_reference_valid)
			{
				reference_latitude = hil_state_quaternion.lat;
				reference_longitude = hil_state_quaternion.lon;
				reference_altitude = hil_state_quaternion.alt;
				is_reference_valid = true;
			}

			if (is_reference_valid)
			{
				// calculate ned position from reference lat, lon, alt
				static constexpr double CONSTANTS_RADIUS_OF_EARTH = 6371000;
				static constexpr double DEG_TO_RAD = M_PI / 180.0;
				const double COS_LAT0 = cos(reference_latitude * 1.0e-7 * DEG_TO_RAD);

				position.x = double(hil_state_quaternion.lat - reference_latitude) * 1.0e-7 * DEG_TO_RAD * CONSTANTS_RADIUS_OF_EARTH;
				position.y = double(hil_state_quaternion.lon - reference_longitude) * 1.0e-7 * COS_LAT0 * DEG_TO_RAD * CONSTANTS_RADIUS_OF_EARTH;
				position.z = (reference_altitude - hil_state_quaternion.alt) * 1.0e-3;

				if (ned_to_eus)
					position = NED2EUS::ned_to_eus_v(position);
			}

			orientation = Quaternion(hil_state_quaternion.attitude_quaternion[1],
									 hil_state_quaternion.attitude_quaternion[2],
									 hil_state_quaternion.attitude_quaternion[3],
									 hil_state_quaternion.attitude_quaternion[0]);
			if (ned_to_eus)
				orientation = NED2EUS::ned_to_eus_q(orientation);

			if (is_reference_valid)
				call_deferred("emit_signal", "pose_subscribed", position, orientation);
		}
		break;
		}
	}
	break;

	case OdometrySource::ODOMETRY_ESTIMATION:
	{
		switch (mavlink_message.msgid)
		{
		case MAVLINK_MSG_ID_LOCAL_POSITION_NED:
		{
			mavlink_local_position_ned_t local_position_ned;
			mavlink_msg_local_position_ned_decode(&mavlink_message, &local_position_ned);
			position = Vector3(local_position_ned.x, local_position_ned.y, local_position_ned.z);

			if (ned_to_eus)
				position = NED2EUS::ned_to_eus_v(position);

			call_deferred("emit_signal", "pose_subscribed", position, orientation);
		}
		break;

		case MAVLINK_MSG_ID_ATTITUDE_QUATERNION:
		{
			mavlink_attitude_quaternion_t attitude_quaternion;
			mavlink_msg_attitude_quaternion_decode(&mavlink_message, &attitude_quaternion);
			orientation = Quaternion(attitude_quaternion.q2, attitude_quaternion.q3, attitude_quaternion.q4, attitude_quaternion.q1);

			if (ned_to_eus)
				orientation = NED2EUS::ned_to_eus_q(orientation);

			call_deferred("emit_signal", "pose_subscribed", position, orientation);
		}
		break;
		}
	}
	break;
	}
}

void GoMAVSDK::_on_response_manual_control(GoMAVSDKServer::ManualControlResult result)
{
	if (sys_enable)
	{
		call_deferred("emit_signal", "response_manual_control", result);
	}
}

void GoMAVSDK::_on_response_action(GoMAVSDKServer::ActionResult result)
{
	if (sys_enable)
	{
		call_deferred("emit_signal", "response_action", result);
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
	ADD_SIGNAL(MethodInfo("response_action", PropertyInfo(Variant::INT, "result")));

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

	ClassDB::bind_method(D_METHOD("request_arm"), &GoMAVSDK::request_arm);
	ClassDB::bind_method(D_METHOD("request_disarm"), &GoMAVSDK::request_disarm);
	ClassDB::bind_method(D_METHOD("request_takeoff"), &GoMAVSDK::request_takeoff);
	ClassDB::bind_method(D_METHOD("request_land"), &GoMAVSDK::request_land);
	ClassDB::bind_method(D_METHOD("request_reboot"), &GoMAVSDK::request_reboot);
	ClassDB::bind_method(D_METHOD("request_shutdown"), &GoMAVSDK::request_shutdown);
	ClassDB::bind_method(D_METHOD("request_terminate"), &GoMAVSDK::request_terminate);
	ClassDB::bind_method(D_METHOD("request_kill"), &GoMAVSDK::request_kill);
	ClassDB::bind_method(D_METHOD("request_return_to_launch"), &GoMAVSDK::request_return_to_launch);
	ClassDB::bind_method(D_METHOD("request_hold"), &GoMAVSDK::request_hold);

	BIND_ENUM_CONSTANT(ODOMETRY_GROUND_TRUTH);
	BIND_ENUM_CONSTANT(ODOMETRY_ESTIMATION);

	ClassDB::bind_method(D_METHOD("set_odometry_source", "odometry_source"), &GoMAVSDK::set_odometry_source);
	ClassDB::bind_method(D_METHOD("get_odometry_source"), &GoMAVSDK::get_odometry_source);
	ADD_PROPERTY(PropertyInfo(Variant::INT, "odometry_source", PROPERTY_HINT_ENUM, "GROUND_TRUTH,ESTIMATION"), "set_odometry_source", "get_odometry_source");

	ClassDB::bind_method(D_METHOD("set_ned_to_eus", "ned_to_eus"), &GoMAVSDK::set_ned_to_eus);
	ClassDB::bind_method(D_METHOD("get_ned_to_eus"), &GoMAVSDK::get_ned_to_eus);
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "ned_to_eus"), "set_ned_to_eus", "get_ned_to_eus");

	ADD_SIGNAL(MethodInfo("pose_subscribed", PropertyInfo(Variant::VECTOR3, "position"), PropertyInfo(Variant::QUATERNION, "orientation")));

	ClassDB::bind_method(D_METHOD("set_position", "position"), &GoMAVSDK::set_position);
	ClassDB::bind_method(D_METHOD("get_position"), &GoMAVSDK::get_position);
	ADD_PROPERTY(PropertyInfo(Variant::VECTOR3, "position"), "set_position", "get_position");

	ClassDB::bind_method(D_METHOD("set_orientation", "orientation"), &GoMAVSDK::set_orientation);
	ClassDB::bind_method(D_METHOD("get_orientation"), &GoMAVSDK::get_orientation);
	ADD_PROPERTY(PropertyInfo(Variant::QUATERNION, "orientation"), "set_orientation", "get_orientation");
}
