#pragma once

#include "ros2dds.h"

using namespace godot;

class Subscriber : public ROS2DDS
{
	GDCLASS(Subscriber, ROS2DDS)

public:
	Subscriber();
	virtual ~Subscriber();
	bool _initialize(eprosima::fastdds::dds::Topic *topic, eprosima::fastdds::dds::DataWriterQos &_, eprosima::fastdds::dds::DataReaderQos &qos) override;
	void _deinitialize() override;

protected:
	static void _bind_methods();
	virtual void _on_data_subscribed(void *data){};
	void *_data{nullptr};

	eprosima::fastdds::dds::Subscriber *_subscriber{nullptr};
	eprosima::fastdds::dds::DataReader *_reader{nullptr};

	class _ReaderListener : public eprosima::fastdds::dds::DataReaderListener
	{
	public:
		_ReaderListener(Subscriber &subscriber) : _subscriber(subscriber) {}
		Subscriber &_subscriber;
		void on_subscription_matched(
			eprosima::fastdds::dds::DataReader *reader,
			const eprosima::fastdds::dds::SubscriptionMatchedStatus &info) override
		{
			_matched = info.total_count;
		}

		void on_data_available(eprosima::fastdds::dds::DataReader *reader) override
		{
			eprosima::fastdds::dds::SampleInfo info;
			while (reader->take_next_sample(_subscriber._data, &info) == ReturnCode_t::RETCODE_OK)
			{
				if (info.valid_data)
				{
					_subscriber._on_data_subscribed(_subscriber._data);
				}
			}
		}

		int _matched{0};
	} _reader_listener{*this};
};