#pragma once

#include <godot_cpp/variant/variant.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/basis.hpp>
#include <godot_cpp/variant/quaternion.hpp>
#include <godot_cpp/variant/transform3d.hpp>
#include <godot_cpp/variant/vector3.hpp>

using namespace godot;

class NED2EUS : public Object {
	GDCLASS(NED2EUS, Object)

public:
    static void _bind_methods();

    enum Frame {
        FRAME_GLOBAL,
        FRAME_LOCAL
    };

    static Vector3 ned_to_eus_v(const Vector3& ned, Frame frame = Frame::FRAME_GLOBAL);
    static Vector3 eus_to_ned_v(const Vector3& eus, Frame frame = Frame::FRAME_GLOBAL);
    static Basis ned_to_eus_b(const Basis& ned);
    static Basis eus_to_ned_b(const Basis& eus);
    static Quaternion ned_to_eus_q(const Quaternion& ned);
    static Quaternion eus_to_ned_q(const Quaternion& eus);
};

VARIANT_ENUM_CAST(NED2EUS::Frame);
