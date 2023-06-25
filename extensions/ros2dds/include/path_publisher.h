#pragma once

#include "enu2eus.h"
#include "nav_msgs/msg/PathPubSubTypes.h"
#include "publisher.h"

using namespace godot;

class PathPublisher : public Publisher {
	GDCLASS(PathPublisher, Publisher)
public:
	bool publish(const PackedVector3Array &path) {
		updateHeader(_path);

		_path.poses().resize(path.size());
		if (eus_to_enu) {
			for (int i = 0; i < path.size(); i++) {
				const Vector3 position = ENU2EUS::eus_to_enu_v(path[i]);
				_path.poses()[i].pose().position() = conversion(position);
			}
		} else {
			for (int i = 0; i < path.size(); i++) {
				_path.poses()[i].pose().position() = conversion(path[i]);
			}
		}

		return _publish(&_path);
	}

	void set_eus_to_enu(bool p_eus_to_enu) { eus_to_enu = p_eus_to_enu; };
	bool get_eus_to_enu() { return eus_to_enu; };
	bool eus_to_enu{ true };

protected:
	static void _bind_methods() {
		ClassDB::bind_method(D_METHOD("set_eus_to_enu", "eus_to_enu"), &PathPublisher::set_eus_to_enu);
		ClassDB::bind_method(D_METHOD("get_eus_to_enu"), &PathPublisher::get_eus_to_enu);
		ADD_PROPERTY(PropertyInfo(Variant::BOOL, "eus_to_enu"), "set_eus_to_enu", "get_eus_to_enu");

		ClassDB::bind_method(D_METHOD("publish", "path"), &PathPublisher::publish);
	}

private:
	nav_msgs::msg::Path _path{};
	eprosima::fastdds::dds::TypeSupport _set_type() override {
		return eprosima::fastdds::dds::TypeSupport(new nav_msgs::msg::PathPubSubType());
	}
};