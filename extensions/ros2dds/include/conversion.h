#pragma once

#include "geometry_msgs/msg/Point.h"
#include "geometry_msgs/msg/Quaternion.h"
#include "geometry_msgs/msg/Vector3.h"
#include <godot_cpp/variant/variant.hpp>

_FORCE_INLINE_ godot::Vector3 conversion(const geometry_msgs::msg::Point &point) {
	return godot::Vector3{ (real_t)point.x(), (real_t)point.y(), (real_t)point.z() };
}

_FORCE_INLINE_ godot::Vector3 conversion(const geometry_msgs::msg::Vector3 &point) {
	return godot::Vector3{ (real_t)point.x(), (real_t)point.y(), (real_t)point.z() };
}

_FORCE_INLINE_ geometry_msgs::msg::Vector3 conversion_v(const godot::Vector3 &vector3) {
	geometry_msgs::msg::Vector3 result;
	result.x() = vector3.x;
	result.y() = vector3.y;
	result.z() = vector3.z;
	return result;
}

_FORCE_INLINE_ geometry_msgs::msg::Point conversion(const godot::Vector3 &vector3) {
	geometry_msgs::msg::Point result;
	result.x() = vector3.x;
	result.y() = vector3.y;
	result.z() = vector3.z;
	return result;
}

_FORCE_INLINE_ godot::Quaternion conversion(const geometry_msgs::msg::Quaternion &quaternion) {
	return godot::Quaternion{ (real_t)quaternion.x(), (real_t)quaternion.y(), (real_t)quaternion.z(), (real_t)quaternion.w() };
}

_FORCE_INLINE_ geometry_msgs::msg::Quaternion conversion(const godot::Quaternion &quaternion) {
	geometry_msgs::msg::Quaternion result;
	result.w() = quaternion.w;
	result.x() = quaternion.x;
	result.y() = quaternion.y;
	result.z() = quaternion.z;
	return result;
}