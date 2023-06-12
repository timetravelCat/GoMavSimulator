#include <subscriber.h>

Subscriber::Subscriber() {}

Subscriber::~Subscriber()
{
	if (_reader != nullptr)
	{
		_subscriber->delete_datareader(_reader);
	}
	if (_subscriber != nullptr)
	{
		_participant->delete_subscriber(_subscriber);
	}
}

void Subscriber::_enter_tree()
{
	ROS2DDS::_enter_tree();
	_data = _set_type().create_data();
	_initialization();
};

void Subscriber::_exit_tree()
{
	if (_data != nullptr)
	{
		_set_type().delete_data(_data);
	}
};

bool Subscriber::_initialize(eprosima::fastdds::dds::Topic *topic, eprosima::fastdds::dds::DataWriterQos &_, eprosima::fastdds::dds::DataReaderQos &qos)
{
	_subscriber = _participant->create_subscriber(eprosima::fastdds::dds::SUBSCRIBER_QOS_DEFAULT, nullptr);
	if (!_subscriber)
	{
		return false;
	}

	_reader = _subscriber->create_datareader(_topic, qos, &_reader_listener);
	if (!_reader)
	{
		return false;
	}

	return true;
}

void Subscriber::_bind_methods() {}