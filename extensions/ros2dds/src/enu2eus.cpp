#include <enu2eus.h>

void ENU2EUS::_bind_methods() {
	BIND_ENUM_CONSTANT(FRAME_GLOBAL);
	BIND_ENUM_CONSTANT(FRAME_LOCAL);

	ClassDB::bind_static_method("ENU2EUS", D_METHOD("enu_to_eus_v", "enu", "frame"), &ENU2EUS::enu_to_eus_v, DEFVAL(FRAME_GLOBAL));
	ClassDB::bind_static_method("ENU2EUS", D_METHOD("eus_to_enu_v", "eus", "frame"), &ENU2EUS::eus_to_enu_v, DEFVAL(FRAME_GLOBAL));
	ClassDB::bind_static_method("ENU2EUS", D_METHOD("enu_to_eus_b", "enu"), &ENU2EUS::enu_to_eus_b);
	ClassDB::bind_static_method("ENU2EUS", D_METHOD("eus_to_enu_b", "eus"), &ENU2EUS::eus_to_enu_b);
	ClassDB::bind_static_method("ENU2EUS", D_METHOD("enu_to_eus_q", "enu"), &ENU2EUS::enu_to_eus_q);
	ClassDB::bind_static_method("ENU2EUS", D_METHOD("eus_to_enu_q", "eus"), &ENU2EUS::eus_to_enu_q);
}

Vector3 ENU2EUS::enu_to_eus_v(const Vector3 &enu, Frame frame) {
	return Vector3{ enu.x, enu.z, -enu.y };
}

Vector3 ENU2EUS::eus_to_enu_v(const Vector3 &eus, Frame frame) {
	return Vector3{ eus.x, -eus.z, eus.y };
}

Basis ENU2EUS::enu_to_eus_b(const Basis &enu) {
	return Basis{ enu_to_eus_v(enu.get_column(0)), enu_to_eus_v(enu.get_column(2)), -enu_to_eus_v(enu.get_column(1)) };
}

Basis ENU2EUS::eus_to_enu_b(const Basis &eus) {
	return Basis{ eus_to_enu_v(eus.get_column(0)), -eus_to_enu_v(eus.get_column(2)), eus_to_enu_v(eus.get_column(1)) };
}

Quaternion ENU2EUS::enu_to_eus_q(const Quaternion &enu) {
	return enu_to_eus_b(Basis{ enu }).get_quaternion();
}

Quaternion ENU2EUS::eus_to_enu_q(const Quaternion &eus) {
	return eus_to_enu_b(Basis{ eus }).get_quaternion();
}
