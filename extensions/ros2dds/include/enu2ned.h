#pragma once

#include <godot_cpp/variant/variant.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/basis.hpp>
#include <godot_cpp/variant/quaternion.hpp>
#include <godot_cpp/variant/transform3d.hpp>
#include <godot_cpp/variant/vector3.hpp>

using namespace godot;

class ENU2NED : public Object {
	GDCLASS(ENU2NED, Object)

public:
    static void _bind_methods();

    enum Frame {
        FRAME_GLOBAL,
        FRAME_LOCAL
    };

    static Vector3 ned_to_enu_v(const Vector3& ned, Frame frame = Frame::FRAME_GLOBAL);
    static Vector3 enu_to_ned_v(const Vector3& enu, Frame frame = Frame::FRAME_GLOBAL);
    static Basis ned_to_enu_b(const Basis& ned);
    static Basis enu_to_ned_b(const Basis& enu);
    static Quaternion ned_to_enu_q(const Quaternion& ned);
    static Quaternion enu_to_ned_q(const Quaternion& enu);
};

VARIANT_ENUM_CAST(ENU2NED::Frame);
