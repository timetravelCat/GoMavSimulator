#pragma once

#include "enu2eus.h"
#include "geometry_msgs/msg/PoseStampedPubSubTypes.h"
#include "publisher.h"

using namespace godot;

class PoseStampedPublisher : public Publisher {
	GDCLASS(PoseStampedPublisher, Publisher)
public:
	bool publish(Vector3 position, Quaternion orientation) {
		updateHeader(poseStamped);
		if (eus_to_enu) {
			position = ENU2EUS::eus_to_enu_v(position);
			orientation = ENU2EUS::eus_to_enu_q(orientation);
		}
		poseStamped.pose().position() = conversion(position);
		poseStamped.pose().orientation() = conversion(orientation);
		return _publish(&poseStamped);
	}

	void set_eus_to_enu(bool p_eus_to_enu) { eus_to_enu = p_eus_to_enu; };
	bool get_eus_to_enu() { return eus_to_enu; };
	bool eus_to_enu{ true };

	Node3D *node3d{ nullptr };
	void set_node3d(Node3D *p_node3d) {
		if (node3d == p_node3d) {
			return;
		}
		node3d = p_node3d;
	}
	Node3D *get_node3d() { return node3d; }

	bool global{ true };
	void set_global(bool p_global) { global = p_global; }
	bool get_global() { return global; }

	bool publish_node3d() {
		if (node3d == nullptr)
			return false;

		Vector3 position;
		Quaternion orientation;
		if (global) {
			position = node3d->get_global_position();
			orientation = node3d->get_global_transform().get_basis().get_quaternion();
		} else {
			position = node3d->get_position();
			orientation = node3d->get_transform().get_basis().get_quaternion();
		}
		return publish(position, orientation);
	}

protected:
	static void _bind_methods() {
		ClassDB::bind_method(D_METHOD("set_eus_to_enu", "eus_to_enu"), &PoseStampedPublisher::set_eus_to_enu);
		ClassDB::bind_method(D_METHOD("get_eus_to_enu"), &PoseStampedPublisher::get_eus_to_enu);
		ADD_PROPERTY(PropertyInfo(Variant::BOOL, "eus_to_enu"), "set_eus_to_enu", "get_eus_to_enu");

		ClassDB::bind_method(D_METHOD("publish", "position", "orientation"), &PoseStampedPublisher::publish);

		ClassDB::bind_method(D_METHOD("set_node3d", "node3d"), &PoseStampedPublisher::set_node3d);
		ClassDB::bind_method(D_METHOD("get_node3d"), &PoseStampedPublisher::get_node3d);
		ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "node3d", PROPERTY_HINT_NODE_TYPE, "Node3D"), "set_node3d", "get_node3d");
		ClassDB::bind_method(D_METHOD("set_global", "global"), &PoseStampedPublisher::set_global);
		ClassDB::bind_method(D_METHOD("get_global"), &PoseStampedPublisher::get_global);
		ADD_PROPERTY(PropertyInfo(Variant::BOOL, "global"), "set_global", "get_global");
		ClassDB::bind_method(D_METHOD("publish_node3d"), &PoseStampedPublisher::publish_node3d);
	}

private:
	geometry_msgs::msg::PoseStamped poseStamped{};
	eprosima::fastdds::dds::TypeSupport _set_type() override {
		return eprosima::fastdds::dds::TypeSupport(new geometry_msgs::msg::PoseStampedPubSubType());
	}
};