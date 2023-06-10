#include <coordinate_3d.h>

Coordinate3D *Coordinate3D::singleton = nullptr;

Coordinate3D *Coordinate3D::get_singleton() {
	return singleton;
}

void Coordinate3D::_bind_methods() {
	BIND_ENUM_CONSTANT(FRAME_GLOBAL);
	BIND_ENUM_CONSTANT(FRAME_LOCAL);

	ClassDB::bind_method(D_METHOD("ned_to_enu_v", "ned", "frame"), &Coordinate3D::ned_to_enu_v, DEFVAL(FRAME_GLOBAL));
	ClassDB::bind_method(D_METHOD("enu_to_ned_v", "enu", "frame"), &Coordinate3D::enu_to_ned_v, DEFVAL(FRAME_GLOBAL));
	ClassDB::bind_method(D_METHOD("ned_to_enu_b", "ned"), &Coordinate3D::ned_to_enu_b);
	ClassDB::bind_method(D_METHOD("enu_to_ned_b", "enu"), &Coordinate3D::enu_to_ned_b);
	ClassDB::bind_method(D_METHOD("ned_to_enu_q", "ned"), &Coordinate3D::ned_to_enu_q);
	ClassDB::bind_method(D_METHOD("enu_to_ned_q", "enu"), &Coordinate3D::enu_to_ned_q);
	ClassDB::bind_method(D_METHOD("ned_to_eus_v", "ned", "frame"), &Coordinate3D::ned_to_eus_v, DEFVAL(FRAME_GLOBAL));
	ClassDB::bind_method(D_METHOD("eus_to_ned_v", "eus", "frame"), &Coordinate3D::eus_to_ned_v, DEFVAL(FRAME_GLOBAL));
	ClassDB::bind_method(D_METHOD("ned_to_eus_b", "ned"), &Coordinate3D::ned_to_eus_b);
	ClassDB::bind_method(D_METHOD("eus_to_ned_b", "eus"), &Coordinate3D::eus_to_ned_b);
	ClassDB::bind_method(D_METHOD("ned_to_eus_q", "ned"), &Coordinate3D::ned_to_eus_q);
	ClassDB::bind_method(D_METHOD("eus_to_ned_q", "eus"), &Coordinate3D::eus_to_ned_q);
	ClassDB::bind_method(D_METHOD("enu_to_eus_v", "enu", "frame"), &Coordinate3D::enu_to_eus_v, DEFVAL(FRAME_GLOBAL));
	ClassDB::bind_method(D_METHOD("eus_to_enu_v", "eus", "frame"), &Coordinate3D::eus_to_enu_v, DEFVAL(FRAME_GLOBAL));
	ClassDB::bind_method(D_METHOD("enu_to_eus_b", "enu"), &Coordinate3D::enu_to_eus_b);
	ClassDB::bind_method(D_METHOD("eus_to_enu_b", "eus"), &Coordinate3D::eus_to_enu_b);
	ClassDB::bind_method(D_METHOD("enu_to_eus_q", "enu"), &Coordinate3D::enu_to_eus_q);
	ClassDB::bind_method(D_METHOD("eus_to_enu_q", "eus"), &Coordinate3D::eus_to_enu_q);
}

Vector3 Coordinate3D::ned_to_enu_v(const Vector3 &ned, Frame frame) {
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

Vector3 Coordinate3D::enu_to_ned_v(const Vector3 &enu, Frame frame) {
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

Basis Coordinate3D::ned_to_enu_b(const Basis &ned) {
	return Basis{ ned_to_enu_v(ned.get_column(0)), -ned_to_enu_v(ned.get_column(1)), -ned_to_enu_v(ned.get_column(2)) };
}

Basis Coordinate3D::enu_to_ned_b(const Basis &enu) {
	return Basis{ enu_to_ned_v(enu.get_column(0)), -enu_to_ned_v(enu.get_column(1)), -enu_to_ned_v(enu.get_column(2)) };
}

Quaternion Coordinate3D::ned_to_enu_q(const Quaternion &ned) {
	return ned_to_enu_b(Basis{ ned }).get_quaternion();
}

Quaternion Coordinate3D::enu_to_ned_q(const Quaternion &enu) {
	return ned_to_enu_b(Basis{ enu }).get_quaternion();
}

Vector3 Coordinate3D::ned_to_eus_v(const Vector3 &ned, Frame frame) {
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

Vector3 Coordinate3D::eus_to_ned_v(const Vector3 &eus, Frame frame) {
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

Basis Coordinate3D::ned_to_eus_b(const Basis &ned) {
	return Basis{ ned_to_eus_v(ned.get_column(0)), -ned_to_eus_v(ned.get_column(2)), ned_to_eus_v(ned.get_column(1)) };
}

Basis Coordinate3D::eus_to_ned_b(const Basis &eus) {
	return Basis{ eus_to_ned_v(eus.get_column(0)), eus_to_ned_v(eus.get_column(2)), -eus_to_ned_v(eus.get_column(1)) };
}

Quaternion Coordinate3D::ned_to_eus_q(const Quaternion &ned) {
	return ned_to_eus_b(Basis{ ned }).get_quaternion();
}

Quaternion Coordinate3D::eus_to_ned_q(const Quaternion &eus) {
	return eus_to_ned_b(Basis{ eus }).get_quaternion();
}

Vector3 Coordinate3D::enu_to_eus_v(const Vector3 &enu, Frame frame) {
	return Vector3{ enu.x, enu.z, -enu.y };
}

Vector3 Coordinate3D::eus_to_enu_v(const Vector3 &eus, Frame frame) {
	return Vector3{ eus.x, -eus.z, eus.y };
}

Basis Coordinate3D::enu_to_eus_b(const Basis &enu) {
	return Basis{ enu_to_eus_v(enu.get_column(0)), enu_to_eus_v(enu.get_column(2)), -enu_to_eus_v(enu.get_column(1)) };
}

Basis Coordinate3D::eus_to_enu_b(const Basis &eus) {
	return Basis{ eus_to_enu_v(eus.get_column(0)), -eus_to_enu_v(eus.get_column(2)), eus_to_enu_v(eus.get_column(1)) };
}

Quaternion Coordinate3D::enu_to_eus_q(const Quaternion &enu) {
	return enu_to_eus_b(Basis{ enu }).get_quaternion();
}

Quaternion Coordinate3D::eus_to_enu_q(const Quaternion &eus) {
	return eus_to_enu_b(Basis{ eus }).get_quaternion();
}
