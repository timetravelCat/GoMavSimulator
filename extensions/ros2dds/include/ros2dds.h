#pragma once

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/time.hpp>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/variant/variant.hpp>
#include <godot_cpp/variant/quaternion.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include <godot_cpp/variant/transform3d.hpp>
#include <godot_cpp/classes/wrapped.hpp>

#include "conversion.h"
#include "std_msgs/msg/Header.h"
#include <fastdds/dds/domain/DomainParticipant.hpp>
#include <fastdds/dds/publisher/DataWriter.hpp>
#include <fastdds/dds/publisher/DataWriterListener.hpp>
#include <fastdds/dds/publisher/Publisher.hpp>

#include <fastdds/dds/subscriber/DataReader.hpp>
#include <fastdds/dds/subscriber/DataReaderListener.hpp>
#include <fastdds/dds/subscriber/Subscriber.hpp>

#include <fastdds/dds/topic/TypeSupport.hpp>

using namespace godot;

class ROS2DDS : public Node
{
	GDCLASS(ROS2DDS, Node)

public:
	ROS2DDS();
	virtual ~ROS2DDS();

	enum QoSOption
	{
		QOS_FASTEST,
		QOS_NORMAL
	};

	void set_qos_option(QoSOption p_qos_option)
	{
		qos_option = p_qos_option;
		initialize();
	};
	QoSOption get_qos_option() { return qos_option; };
	QoSOption qos_option{QoSOption::QOS_FASTEST};

	void set_domain_id(int p_domain_id)
	{
		domain_id = p_domain_id;
		initialize();
	};
	int get_domain_id() { return domain_id; };
	int domain_id{0};

	void set_domain_name(String p_domain_name)
	{
		domain_name = p_domain_name;
		initialize();
	};
	String get_domain_name() { return domain_name; };
	String domain_name{"ROS2DDS"};

	void set_topic_name(String p_topic_name)
	{
		topic_name = p_topic_name;
		initialize();
	};
	String get_topic_name() { return topic_name; };
	String topic_name{""};

	String get_topic_type() { return topic_type; }
	String topic_type{""};
	bool initialize() { return _initialization(true); };

protected:
	static void _bind_methods();

	virtual eprosima::fastdds::dds::TypeSupport _set_type() { return eprosima::fastdds::dds::TypeSupport{}; };
	virtual void _deinitialize(){};
	virtual bool _initialize(eprosima::fastdds::dds::Topic *topic, eprosima::fastdds::dds::DataWriterQos &wqos, eprosima::fastdds::dds::DataReaderQos &rqos) { return false; };

	bool _initialization(bool force);
	bool _initialized{false};

	eprosima::fastdds::dds::DomainParticipant *_participant{nullptr};
	eprosima::fastdds::dds::Topic *_topic{nullptr};
};

VARIANT_ENUM_CAST(ROS2DDS::QoSOption);