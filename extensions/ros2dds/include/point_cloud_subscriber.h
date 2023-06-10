#pragma once

#include "coordinate_3d.h"
#include "sensor_msgs/msg/PointCloud2PubSubTypes.h"
#include "sensor_msgs/point_cloud2_iterator.hpp"
#include "subscriber.h"

using namespace godot;

class PointCloudSubscriber : public Subscriber {
	GDCLASS(PointCloudSubscriber, Subscriber)
public:
	void _on_data_subscribed(void *p_data) override {
		sensor_msgs::msg::PointCloud2 *recv = static_cast<sensor_msgs::msg::PointCloud2 *>(p_data);

		PackedVector3Array positions;
		positions.resize(recv->width() * recv->height());
		sensor_msgs::PointCloud2Iterator<float> iter_x(*recv, "x");
		sensor_msgs::PointCloud2Iterator<float> iter_y(*recv, "y");
		sensor_msgs::PointCloud2Iterator<float> iter_z(*recv, "z");

		if (enu_to_eus) {
			for (int i = 0; i < positions.size(); ++i, ++iter_x, ++iter_y, ++iter_z) {
				positions.set(i, Coordinate3D::get_singleton()->enu_to_eus_v(Vector3{ *iter_x, *iter_y, *iter_z }));
			}
			emit_signal("on_data_subscribed", positions);
			return;
		}

		for (int i = 0; i < positions.size(); ++i, ++iter_x, ++iter_y, ++iter_z) {
			positions.set(i, Vector3{ *iter_x, *iter_y, *iter_z });
		}

		emit_signal("on_data_subscribed", positions);
		return;
	}

	void set_enu_to_eus(bool p_enu_to_eus) { enu_to_eus = p_enu_to_eus; };
	bool get_enu_to_eus() { return enu_to_eus; };
	bool enu_to_eus{ true };

protected:
	static void _bind_methods() {
		ClassDB::bind_method(D_METHOD("set_enu_to_eus", "enu_to_eus"), &PointCloudSubscriber::set_enu_to_eus);
		ClassDB::bind_method(D_METHOD("get_enu_to_eus"), &PointCloudSubscriber::get_enu_to_eus);
		ADD_PROPERTY(PropertyInfo(Variant::BOOL, "enu_to_eus"), "set_enu_to_eus", "get_enu_to_eus");

		ADD_SIGNAL(MethodInfo("on_data_subscribed", PropertyInfo(Variant::PACKED_VECTOR3_ARRAY, "positions")));
	}

private:
	eprosima::fastdds::dds::TypeSupport _set_type() override {
		return eprosima::fastdds::dds::TypeSupport(new sensor_msgs::msg::PointCloud2PubSubType());
	}
};