#pragma once

#include <godot_cpp/variant/variant.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/basis.hpp>
#include <godot_cpp/variant/quaternion.hpp>
#include <godot_cpp/variant/transform3d.hpp>
#include <godot_cpp/variant/vector3.hpp>

using namespace godot;

class Coordinate3D : public Object {
	GDCLASS(Coordinate3D, Object)
	static Coordinate3D *singleton;

public:
	Coordinate3D() { singleton = this; }
	static Coordinate3D *get_singleton();
    static void _bind_methods();

    enum Frame {
        FRAME_GLOBAL,
        FRAME_LOCAL
    };

    Vector3 ned_to_enu_v(const Vector3& ned, Frame frame = Frame::FRAME_GLOBAL);
    Vector3 enu_to_ned_v(const Vector3& enu, Frame frame = Frame::FRAME_GLOBAL);
    Basis ned_to_enu_b(const Basis& ned);
    Basis enu_to_ned_b(const Basis& enu);
    Quaternion ned_to_enu_q(const Quaternion& ned);
    Quaternion enu_to_ned_q(const Quaternion& enu);

    Vector3 ned_to_eus_v(const Vector3& ned, Frame frame = Frame::FRAME_GLOBAL);
    Vector3 eus_to_ned_v(const Vector3& eus, Frame frame = Frame::FRAME_GLOBAL);
    Basis ned_to_eus_b(const Basis& ned);
    Basis eus_to_ned_b(const Basis& eus);
    Quaternion ned_to_eus_q(const Quaternion& ned);
    Quaternion eus_to_ned_q(const Quaternion& eus);

    Vector3 enu_to_eus_v(const Vector3& enu, Frame frame = Frame::FRAME_GLOBAL);
    Vector3 eus_to_enu_v(const Vector3& eus, Frame frame = Frame::FRAME_GLOBAL);
    Basis enu_to_eus_b(const Basis& enu);
    Basis eus_to_enu_b(const Basis& eus);
    Quaternion enu_to_eus_q(const Quaternion& enu);
    Quaternion eus_to_enu_q(const Quaternion& eus);
};

VARIANT_ENUM_CAST(Coordinate3D::Frame);
