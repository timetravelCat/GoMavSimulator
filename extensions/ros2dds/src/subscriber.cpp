#include <subscriber.h>

Subscriber::Subscriber() {}

Subscriber::~Subscriber() {
	if (_reader != nullptr) {
		_subscriber->delete_datareader(_reader);
	}
	if (_subscriber != nullptr) {
		_participant->delete_subscriber(_subscriber);
	}
}

void Subscriber::_notification(int p_notification) {
	switch (p_notification) {
		case NOTIFICATION_POSTINITIALIZE: {
			_data = _set_type().create_data();
		} break;

		case NOTIFICATION_PREDELETE: {
			if (_data != nullptr) {
				_set_type().delete_data(_data);
			}
		} break;
	}
}

bool Subscriber::_initialize(eprosima::fastdds::dds::Topic *topic, eprosima::fastdds::dds::DataWriterQos &_, eprosima::fastdds::dds::DataReaderQos &qos) {
	_subscriber = _participant->create_subscriber(eprosima::fastdds::dds::SUBSCRIBER_QOS_DEFAULT, nullptr);
	if (!_subscriber) {
		return false;
	}

	_reader = _subscriber->create_datareader(_topic, qos, &_reader_listener);
	if (!_reader) {
		return false;
	}

	return true;
}

void Subscriber::_bind_methods() {}