#pragma once

#include <godot_cpp/variant/variant.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/basis.hpp>
#include <godot_cpp/variant/quaternion.hpp>
#include <godot_cpp/variant/transform3d.hpp>
#include <godot_cpp/variant/vector3.hpp>

using namespace godot;

class ENU2EUS : public Object {
	GDCLASS(ENU2EUS, Object)

public:
    static void _bind_methods();

    enum Frame {
        FRAME_GLOBAL,
        FRAME_LOCAL
    };

    static Vector3 enu_to_eus_v(const Vector3& enu, Frame frame = Frame::FRAME_GLOBAL);
    static Vector3 eus_to_enu_v(const Vector3& eus, Frame frame = Frame::FRAME_GLOBAL);
    static Basis enu_to_eus_b(const Basis& enu);
    static Basis eus_to_enu_b(const Basis& eus);
    static Quaternion enu_to_eus_q(const Quaternion& enu);
    static Quaternion eus_to_enu_q(const Quaternion& eus);
};

VARIANT_ENUM_CAST(ENU2EUS::Frame);
