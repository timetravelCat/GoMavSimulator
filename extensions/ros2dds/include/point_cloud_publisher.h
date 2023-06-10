#pragma once

#include "coordinate_3d.h"
#include "publisher.h"
#include "sensor_msgs/msg/PointCloud2PubSubTypes.h"
#include "sensor_msgs/point_cloud2_iterator.hpp"

using namespace godot;

class PointCloudPublisher : public Publisher {
	GDCLASS(PointCloudPublisher, Publisher)
public:
	bool publish(const PackedVector3Array &positions) {
		updateHeader(pointCloud);
		pointCloud.height() = 1;
		pointCloud.width() = positions.size();
		sensor_msgs::PointCloud2Modifier modifier(pointCloud);
		modifier.setPointCloud2FieldsByString(1, "xyz");
		modifier.resize(positions.size());
		sensor_msgs::PointCloud2Iterator<float> iter_x(pointCloud, "x");
		sensor_msgs::PointCloud2Iterator<float> iter_y(pointCloud, "y");
		sensor_msgs::PointCloud2Iterator<float> iter_z(pointCloud, "z");
		if (eus_to_enu) {
			for (int i = 0; i < positions.size(); ++i, ++iter_x, ++iter_y, ++iter_z) {
				const Vector3 position = Coordinate3D::get_singleton()->eus_to_enu_v(positions[i]);
				*iter_x = position.x;
				*iter_y = position.y;
				*iter_z = position.z;
			}
			return _publish(&pointCloud);
		}

		for (int i = 0; i < positions.size(); ++i, ++iter_x, ++iter_y, ++iter_z) {
			*iter_x = positions[i].x;
			*iter_y = positions[i].y;
			*iter_z = positions[i].z;
		}

		return _publish(&pointCloud);
	}

	void set_eus_to_enu(bool p_eus_to_enu) { eus_to_enu = p_eus_to_enu; };
	bool get_eus_to_enu() { return eus_to_enu; };
	bool eus_to_enu{ true };

protected:
	static void _bind_methods() {
		ClassDB::bind_method(D_METHOD("set_eus_to_enu", "eus_to_enu"), &PointCloudPublisher::set_eus_to_enu);
		ClassDB::bind_method(D_METHOD("get_eus_to_enu"), &PointCloudPublisher::get_eus_to_enu);
		ADD_PROPERTY(PropertyInfo(Variant::BOOL, "eus_to_enu"), "set_eus_to_enu", "get_eus_to_enu");

		ClassDB::bind_method(D_METHOD("publish", "positions"), &PointCloudPublisher::publish);
	}

private:
	sensor_msgs::msg::PointCloud2 pointCloud{};
	eprosima::fastdds::dds::TypeSupport _set_type() override {
		return eprosima::fastdds::dds::TypeSupport(new sensor_msgs::msg::PointCloud2PubSubType());
	}
};
