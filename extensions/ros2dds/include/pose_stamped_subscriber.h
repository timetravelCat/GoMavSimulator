#pragma once

#include "geometry_msgs/msg/PoseStampedPubSubTypes.h"
#include "subscriber.h"

using namespace godot;

class PoseStampedSubscriber : public Subscriber
{
	GDCLASS(PoseStampedSubscriber, Subscriber)
public:
	void _on_data_subscribed(void *p_data) override
	{
		const geometry_msgs::msg::PoseStamped *recv = static_cast<geometry_msgs::msg::PoseStamped *>(p_data);
		const geometry_msgs::msg::Point &position = recv->pose().position();
		const geometry_msgs::msg::Quaternion &orientation = recv->pose().orientation();
		if (enu_to_eus)
		{
			call_deferred("emit_signal",
						  "on_data_subscribed",
						  ENU2EUS::enu_to_eus_v(conversion(position)),
						  ENU2EUS::enu_to_eus_q(conversion(orientation)));
		}
		else
		{
			call_deferred("emit_signal",
						  "on_data_subscribed",
						  conversion(position),
						  conversion(orientation));
		}
	}

	void set_enu_to_eus(bool p_enu_to_eus) { enu_to_eus = p_enu_to_eus; };
	bool get_enu_to_eus() { return enu_to_eus; };
	bool enu_to_eus{true};

protected:
	static void _bind_methods()
	{
		ClassDB::bind_method(D_METHOD("set_enu_to_eus", "enu_to_eus"), &PoseStampedSubscriber::set_enu_to_eus);
		ClassDB::bind_method(D_METHOD("get_enu_to_eus"), &PoseStampedSubscriber::get_enu_to_eus);
		ADD_PROPERTY(PropertyInfo(Variant::BOOL, "enu_to_eus"), "set_enu_to_eus", "get_enu_to_eus");

		ADD_SIGNAL(MethodInfo("on_data_subscribed", PropertyInfo(Variant::VECTOR3, "position"), PropertyInfo(Variant::QUATERNION, "orientation")));
	}

private:
	eprosima::fastdds::dds::TypeSupport _set_type() override
	{
		return eprosima::fastdds::dds::TypeSupport(new geometry_msgs::msg::PoseStampedPubSubType());
	}
};