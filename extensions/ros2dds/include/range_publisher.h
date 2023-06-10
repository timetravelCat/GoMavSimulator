#pragma once

#include "coordinate_3d.h"
#include "publisher.h"
#include "sensor_msgs/msg/RangePubSubTypes.h"

using namespace godot;

class RangePublisher : public Publisher {
	GDCLASS(RangePublisher, Publisher)
public:
	enum Radiation {
		ULTRASOUND,
		INFRARED
	};

	bool publish(float distance) {
		updateHeader(range);
		range.radiation_type(radiation);
		constexpr static float DEG_TO_RAD = 0.017453292519943295769236907684886f;
		range.field_of_view(field_of_view * DEG_TO_RAD);
		range.max_range(max_range);
		range.min_range(min_range);
		range.range(distance);
		return _publish(&range);
	}

	Radiation get_radiation() { return radiation; }
	void set_radiation(Radiation p_radiation) { radiation = p_radiation; }
	Radiation radiation{ Radiation::INFRARED };

	void set_field_of_view(float p_field_of_view) { field_of_view = p_field_of_view; }
	float get_field_of_view() { return field_of_view; }
	float field_of_view{ 0.0f };
	void set_max_range(float p_max_range) { max_range = p_max_range; }
	float get_max_range() { return max_range; }
	float max_range{ INFINITY };
	void set_min_range(float p_min_range) { min_range = p_min_range; }
	float get_min_range() { return min_range; }
	float min_range{ 0.0f };

protected:
	static void _bind_methods() {
		BIND_ENUM_CONSTANT(ULTRASOUND);
		BIND_ENUM_CONSTANT(INFRARED);

		ClassDB::bind_method(D_METHOD("publish", "distance"), &RangePublisher::publish);

		ClassDB::bind_method(D_METHOD("set_radiation", "radiation"), &RangePublisher::set_radiation);
		ClassDB::bind_method(D_METHOD("get_radiation"), &RangePublisher::get_radiation);
		ADD_PROPERTY(PropertyInfo(Variant::INT, "format", PROPERTY_HINT_ENUM, "ULTRASOUND,INFRARED"), "set_radiation", "get_radiation");

		ClassDB::bind_method(D_METHOD("set_field_of_view", "field_of_view"), &RangePublisher::set_field_of_view);
		ClassDB::bind_method(D_METHOD("get_field_of_view"), &RangePublisher::get_field_of_view);
		ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "field_of_view", PROPERTY_HINT_RANGE, "0,180,0.01,degrees"), "set_field_of_view", "get_field_of_view");

		ClassDB::bind_method(D_METHOD("set_max_range", "max_range"), &RangePublisher::set_max_range);
		ClassDB::bind_method(D_METHOD("get_max_range"), &RangePublisher::get_max_range);
		ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "max_range", PROPERTY_HINT_RANGE, "0,1000,0.01,or_greater,suffix:m"), "set_max_range", "get_max_range");

		ClassDB::bind_method(D_METHOD("set_min_range", "min_range"), &RangePublisher::set_min_range);
		ClassDB::bind_method(D_METHOD("get_min_range"), &RangePublisher::get_min_range);
		ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "min_range", PROPERTY_HINT_RANGE, "0,100,0.01,or_greater,suffix:m"), "set_min_range", "get_min_range");
	}

private:
	sensor_msgs::msg::Range range{};
	eprosima::fastdds::dds::TypeSupport _set_type() override {
		return eprosima::fastdds::dds::TypeSupport(new sensor_msgs::msg::RangePubSubType());
	}
};

VARIANT_ENUM_CAST(RangePublisher::Radiation);
