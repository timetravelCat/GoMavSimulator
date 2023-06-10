#include <ros2dds.h>
#include <fastdds/dds/domain/DomainParticipantFactory.hpp>

using namespace eprosima::fastdds::dds;

ROS2DDS::ROS2DDS() {
}

ROS2DDS::~ROS2DDS() {
	if (_topic != nullptr) {
		_participant->delete_topic(_topic);
	}
	DomainParticipantFactory::get_instance()->delete_participant(_participant);
}

void ROS2DDS::_notification(int p_notification) {
	switch (p_notification) {
		case NOTIFICATION_POSTINITIALIZE: {
			topic_type = String(_set_type().get_type_name().c_str());

		} break;

		case NOTIFICATION_READY: {
			_initialization();
		} break;
	}
}

bool ROS2DDS::_initialization() {
	if (_initialized) {
		return true;
	}

	if (topic_name.is_empty()) {
		WARN_PRINT_ONCE("ROS2DDS initialization failed due to topic name is not assigned.");
		return false;
	}

	DomainParticipantQos pqos;
	pqos.name(domain_name.utf8().get_data());

	_participant = DomainParticipantFactory::get_instance()->create_participant(domain_id, pqos);
	if (!_participant) {
		return false;
	}

	eprosima::fastdds::dds::TypeSupport type = _set_type();
	type.register_type(_participant);

	const std::string _topic_name = "rt/" + std::string{ topic_name.utf8().get_data() };
	_topic = _participant->create_topic(_topic_name, type.get_type_name(), TOPIC_QOS_DEFAULT);

	DataWriterQos wqos = DATAWRITER_QOS_DEFAULT;
	DataReaderQos rqos = DATAREADER_QOS_DEFAULT;

	switch (qos_option) {
		case QoSOption::QOS_FASTEST: {
			wqos.history().kind = KEEP_LAST_HISTORY_QOS;
			wqos.durability().kind = VOLATILE_DURABILITY_QOS;
			wqos.reliability().kind = RELIABLE_RELIABILITY_QOS;
			wqos.history().depth = 1;
			rqos.history().kind = KEEP_LAST_HISTORY_QOS;
			rqos.durability().kind = VOLATILE_DURABILITY_QOS;
			rqos.reliability().kind = RELIABLE_RELIABILITY_QOS;
			rqos.history().depth = 1;
			break;
		}
		case QoSOption::QOS_NORMAL:
		default:
			break;
	}

	if (!_initialize(_topic, wqos, rqos)) {
		return false;
	}

	_initialized = true;
	return true;
}

void ROS2DDS::_bind_methods() {
	BIND_ENUM_CONSTANT(QOS_FASTEST);
	BIND_ENUM_CONSTANT(QOS_NORMAL);

	ClassDB::bind_method(D_METHOD("set_qos_option", "qos_option"), &ROS2DDS::set_qos_option);
	ClassDB::bind_method(D_METHOD("get_qos_option"), &ROS2DDS::get_qos_option);
	ADD_PROPERTY(PropertyInfo(Variant::INT, "qos_option", PROPERTY_HINT_ENUM, "Fastest,Normal"), "set_qos_option", "get_qos_option");

	ClassDB::bind_method(D_METHOD("set_domain_id", "domain_id"), &ROS2DDS::set_domain_id);
	ClassDB::bind_method(D_METHOD("get_domain_id"), &ROS2DDS::get_domain_id);
	ADD_PROPERTY(PropertyInfo(Variant::INT, "domain_id"), "set_domain_id", "get_domain_id");

	ClassDB::bind_method(D_METHOD("set_domain_name", "domain_name"), &ROS2DDS::set_domain_name);
	ClassDB::bind_method(D_METHOD("get_domain_name"), &ROS2DDS::get_domain_name);
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "domain_name"), "set_domain_name", "get_domain_name");

	ClassDB::bind_method(D_METHOD("set_topic_name", "topic_name"), &ROS2DDS::set_topic_name);
	ClassDB::bind_method(D_METHOD("get_topic_name"), &ROS2DDS::get_topic_name);
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "topic_name"), "set_topic_name", "get_topic_name");

	ClassDB::bind_method(D_METHOD("get_topic_type"), &ROS2DDS::get_topic_type);
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "topic_type", PROPERTY_HINT_NONE), "", "get_topic_type");
}