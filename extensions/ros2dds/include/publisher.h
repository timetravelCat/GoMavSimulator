#pragma once

#include "ros2dds.h"
#include <godot_cpp/classes/time.hpp>

using namespace godot;

class Publisher : public ROS2DDS {
	GDCLASS(Publisher, ROS2DDS)

public:
	Publisher();
	virtual ~Publisher();

	bool _publish(void *p_data);
	bool _initialize(eprosima::fastdds::dds::Topic *topic, eprosima::fastdds::dds::DataWriterQos &qos, eprosima::fastdds::dds::DataReaderQos &_) override;

	void set_publish_on_matched(bool p_publish_on_matched) { publish_on_matched = p_publish_on_matched; };
	bool get_publish_on_matched() { return publish_on_matched; };
	bool publish_on_matched{ true };

	void set_frame_id(String p_frame_id) { frame_id = p_frame_id; };
	String get_frame_id() { return frame_id; };
	String frame_id{ "/map" };

protected:
	template <typename StampedMessage>
	void updateHeader(StampedMessage &message) {
		std_msgs::msg::Header &header = message.header();
		header.frame_id() = std::string{ frame_id.utf8().get_data() };

		const uint64_t time_usec = Time::get_singleton()->get_ticks_usec();
		header.stamp().sec() = int32_t(time_usec / 1000000ull);
		header.stamp().nanosec() = uint32_t(1000ull * (time_usec - uint64_t(header.stamp().sec()) * 1000000ull));
	}

	static void _bind_methods();

	eprosima::fastdds::dds::Publisher *_publisher{ nullptr };
	eprosima::fastdds::dds::DataWriter *_writer{ nullptr };

	class : public eprosima::fastdds::dds::DataWriterListener {
	public:
		void on_publication_matched(eprosima::fastdds::dds::DataWriter *writer,
				const eprosima::fastdds::dds::PublicationMatchedStatus &info) override {
			_matched = info.total_count;
		}
		int _matched{ 0 };
	} _writer_listener;
};