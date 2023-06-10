#pragma once

#include "coordinate_3d.h"
#include "geometry_msgs/msg/PointStampedPubSubTypes.h"
#include "publisher.h"

using namespace godot;

class PointStampedPublisher : public Publisher {
	GDCLASS(PointStampedPublisher, Publisher)
public:
	bool publish(Vector3 point) {
		updateHeader(pointStamped);
		if (eus_to_enu) {
			point = Coordinate3D::get_singleton()->eus_to_enu_v(point);
		}

		pointStamped.point() = conversion(point);
		return _publish(&pointStamped);
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

		Vector3 point;
		global ? point = node3d->get_global_position() : point = node3d->get_position();
		return publish(point);
	}

protected:
	static void _bind_methods() {
		ClassDB::bind_method(D_METHOD("set_eus_to_enu", "eus_to_enu"), &PointStampedPublisher::set_eus_to_enu);
		ClassDB::bind_method(D_METHOD("get_eus_to_enu"), &PointStampedPublisher::get_eus_to_enu);
		ADD_PROPERTY(PropertyInfo(Variant::BOOL, "eus_to_enu"), "set_eus_to_enu", "get_eus_to_enu");
		ClassDB::bind_method(D_METHOD("publish", "point"), &PointStampedPublisher::publish);

		ClassDB::bind_method(D_METHOD("set_node3d", "node3d"), &PointStampedPublisher::set_node3d);
		ClassDB::bind_method(D_METHOD("get_node3d"), &PointStampedPublisher::get_node3d);
		ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "node3d", PROPERTY_HINT_NODE_TYPE, "Node3D"), "set_node3d", "get_node3d");
		ClassDB::bind_method(D_METHOD("set_global", "global"), &PointStampedPublisher::set_global);
		ClassDB::bind_method(D_METHOD("get_global"), &PointStampedPublisher::get_global);
		ADD_PROPERTY(PropertyInfo(Variant::BOOL, "global"), "set_global", "get_global");
		ClassDB::bind_method(D_METHOD("publish_node3d"), &PointStampedPublisher::publish_node3d);
	}

private:
	geometry_msgs::msg::PointStamped pointStamped{};
	eprosima::fastdds::dds::TypeSupport _set_type() override {
		return eprosima::fastdds::dds::TypeSupport(new geometry_msgs::msg::PointStampedPubSubType());
	}
};