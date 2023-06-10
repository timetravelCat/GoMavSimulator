#include <publisher.h>

Publisher::Publisher() {}
Publisher::~Publisher() {
	if (_writer != nullptr) {
		_publisher->delete_datawriter(_writer);
	}
	if (_publisher != nullptr) {
		_participant->delete_publisher(_publisher);
	}
}

bool Publisher::_publish(void *p_data) {
	_initialization();

	if (_writer && (publish_on_matched ? _writer_listener._matched > 0 : true)) {
		return _writer->write(p_data);
	}

	return false;
}

bool Publisher::_initialize(eprosima::fastdds::dds::Topic *topic, eprosima::fastdds::dds::DataWriterQos &qos, eprosima::fastdds::dds::DataReaderQos &_) {
	_publisher = _participant->create_publisher(eprosima::fastdds::dds::PUBLISHER_QOS_DEFAULT, nullptr);
	if (!_publisher) {
		return false;
	}

	_writer = _publisher->create_datawriter(_topic, qos, &_writer_listener);
	if (!_writer) {
		return false;
	}

	return true;
}

void Publisher::_bind_methods() {
	ClassDB::bind_method(D_METHOD("set_publish_on_matched", "publish_on_matched"), &Publisher::set_publish_on_matched);
	ClassDB::bind_method(D_METHOD("get_publish_on_matched"), &Publisher::get_publish_on_matched);
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "publish_on_matched"), "set_publish_on_matched", "get_publish_on_matched");

	ClassDB::bind_method(D_METHOD("set_frame_id", "frame_id"), &Publisher::set_frame_id);
	ClassDB::bind_method(D_METHOD("get_frame_id"), &Publisher::get_frame_id);
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "frame_id"), "set_frame_id", "get_frame_id");
}