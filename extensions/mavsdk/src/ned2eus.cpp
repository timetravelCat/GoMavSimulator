#include <ned2eus.h>

void NED2EUS::_bind_methods() {
	BIND_ENUM_CONSTANT(FRAME_GLOBAL);
	BIND_ENUM_CONSTANT(FRAME_LOCAL);

	ClassDB::bind_static_method("NED2EUS", D_METHOD("ned_to_eus_v", "ned", "frame"), &NED2EUS::ned_to_eus_v, DEFVAL(FRAME_GLOBAL));
	ClassDB::bind_static_method("NED2EUS", D_METHOD("eus_to_ned_v", "eus", "frame"), &NED2EUS::eus_to_ned_v, DEFVAL(FRAME_GLOBAL));
	ClassDB::bind_static_method("NED2EUS", D_METHOD("ned_to_eus_b", "ned"), &NED2EUS::ned_to_eus_b);
	ClassDB::bind_static_method("NED2EUS", D_METHOD("eus_to_ned_b", "eus"), &NED2EUS::eus_to_ned_b);
	ClassDB::bind_static_method("NED2EUS", D_METHOD("ned_to_eus_q", "ned"), &NED2EUS::ned_to_eus_q);
	ClassDB::bind_static_method("NED2EUS", D_METHOD("eus_to_ned_q", "eus"), &NED2EUS::eus_to_ned_q);
}

Vector3 NED2EUS::ned_to_eus_v(const Vector3 &ned, Frame frame) {
	switch (frame) {
		default:
		case FRAME_GLOBAL: {
			return Vector3{ ned.y, -ned.z, -ned.x };
		}
		case FRAME_LOCAL: {
			return Vector3{ ned.x, -ned.z, ned.y };
		}
	}
}

Vector3 NED2EUS::eus_to_ned_v(const Vector3 &eus, Frame frame) {
	switch (frame) {
		default:
		case FRAME_GLOBAL: {
			return Vector3{ -eus.z, eus.x, -eus.y };
		}

		case FRAME_LOCAL: {
			return Vector3{ eus.x, eus.z, -eus.y };
		}
	}
}

Basis NED2EUS::ned_to_eus_b(const Basis &ned) {
	return Basis{ ned_to_eus_v(ned.get_column(0)), -ned_to_eus_v(ned.get_column(2)), ned_to_eus_v(ned.get_column(1)) };
}

Basis NED2EUS::eus_to_ned_b(const Basis &eus) {
	return Basis{ eus_to_ned_v(eus.get_column(0)), eus_to_ned_v(eus.get_column(2)), -eus_to_ned_v(eus.get_column(1)) };
}

Quaternion NED2EUS::ned_to_eus_q(const Quaternion &ned) {
	return ned_to_eus_b(Basis{ ned }).get_quaternion();
}

Quaternion NED2EUS::eus_to_ned_q(const Quaternion &eus) {
	return eus_to_ned_b(Basis{ eus }).get_quaternion();
}


