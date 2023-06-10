#pragma once

#include "nav_msgs/msg/PathPubSubTypes.h"
#include "subscriber.h"

using namespace godot;

class PathSubscriber : public Subscriber {
	GDCLASS(PathSubscriber, Subscriber)
public:
	void _on_data_subscribed(void *p_data) override {
		const nav_msgs::msg::Path *recv = static_cast<nav_msgs::msg::Path *>(p_data);
		const std::vector<geometry_msgs::msg::PoseStamped> &poses = recv->poses();

		PackedVector3Array positions;
		positions.resize(poses.size());

		auto iter = poses.begin();
		if (enu_to_eus) {
			for (auto &position : positions) {
				position = Coordinate3D::get_singleton()->enu_to_eus_v(conversion((*iter).pose().position()));
				iter++;
			}

		} else {
			for (auto &position : positions) {
				position = conversion((*iter).pose().position());
				iter++;
			}
		}

		emit_signal("on_data_subscribed", positions);
	}

	void set_enu_to_eus(bool p_enu_to_eus) { enu_to_eus = p_enu_to_eus; };
	bool get_enu_to_eus() { return enu_to_eus; };
	bool enu_to_eus{ true };

protected:
	static void _bind_methods() {
		ClassDB::bind_method(D_METHOD("set_enu_to_eus", "enu_to_eus"), &PathSubscriber::set_enu_to_eus);
		ClassDB::bind_method(D_METHOD("get_enu_to_eus"), &PathSubscriber::get_enu_to_eus);
		ADD_PROPERTY(PropertyInfo(Variant::BOOL, "enu_to_eus"), "set_enu_to_eus", "get_enu_to_eus");

		ADD_SIGNAL(MethodInfo("on_data_subscribed", PropertyInfo(Variant::PACKED_VECTOR3_ARRAY, "path")));
	}

private:
	eprosima::fastdds::dds::TypeSupport _set_type() override {
		return eprosima::fastdds::dds::TypeSupport(new nav_msgs::msg::PathPubSubType());
	}
};