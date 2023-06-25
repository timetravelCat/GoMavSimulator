#include <enu2ned.h>

void ENU2NED::_bind_methods() {
	BIND_ENUM_CONSTANT(FRAME_GLOBAL);
	BIND_ENUM_CONSTANT(FRAME_LOCAL);

	ClassDB::bind_static_method("ENU2NED", D_METHOD("ned_to_enu_v", "ned", "frame"), &ENU2NED::ned_to_enu_v, DEFVAL(FRAME_GLOBAL));
	ClassDB::bind_static_method("ENU2NED", D_METHOD("enu_to_ned_v", "enu", "frame"), &ENU2NED::enu_to_ned_v, DEFVAL(FRAME_GLOBAL));
	ClassDB::bind_static_method("ENU2NED", D_METHOD("ned_to_enu_b", "ned"), &ENU2NED::ned_to_enu_b);
	ClassDB::bind_static_method("ENU2NED", D_METHOD("enu_to_ned_b", "enu"), &ENU2NED::enu_to_ned_b);
	ClassDB::bind_static_method("ENU2NED", D_METHOD("ned_to_enu_q", "ned"), &ENU2NED::ned_to_enu_q);
	ClassDB::bind_static_method("ENU2NED", D_METHOD("enu_to_ned_q", "enu"), &ENU2NED::enu_to_ned_q);
}

Vector3 ENU2NED::ned_to_enu_v(const Vector3 &ned, Frame frame) {
	switch (frame) {
		default:
		case FRAME_GLOBAL: {
			return Vector3{ ned.y, ned.x, -ned.z };
		}

		case FRAME_LOCAL: {
			return Vector3{ ned.x, -ned.y, -ned.z };
		}
	}
}

Vector3 ENU2NED::enu_to_ned_v(const Vector3 &enu, Frame frame) {
	switch (frame) {
		default:
		case FRAME_GLOBAL: {
			return Vector3{ enu.y, enu.x, -enu.z };
		}

		case FRAME_LOCAL: {
			return Vector3{ enu.x, -enu.y, -enu.z };
		}
	}
}

Basis ENU2NED::ned_to_enu_b(const Basis &ned) {
	return Basis{ ned_to_enu_v(ned.get_column(0)), -ned_to_enu_v(ned.get_column(1)), -ned_to_enu_v(ned.get_column(2)) };
}

Basis ENU2NED::enu_to_ned_b(const Basis &enu) {
	return Basis{ enu_to_ned_v(enu.get_column(0)), -enu_to_ned_v(enu.get_column(1)), -enu_to_ned_v(enu.get_column(2)) };
}

Quaternion ENU2NED::ned_to_enu_q(const Quaternion &ned) {
	return ned_to_enu_b(Basis{ ned }).get_quaternion();
}

Quaternion ENU2NED::enu_to_ned_q(const Quaternion &enu) {
	return ned_to_enu_b(Basis{ enu }).get_quaternion();
}
