#pragma once

#include "publisher.h"
#include <godot_cpp/classes/camera3d.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include <godot_cpp/classes/viewport_texture.hpp>
#include <godot_cpp/variant/packed_float32_array.hpp>
#include "sensor_msgs/distortion_models.hpp"
#include "sensor_msgs/msg/CameraInfoPubSubTypes.h"

using namespace godot;

class CameraInfoPublisher : public Publisher {
	GDCLASS(CameraInfoPublisher, Publisher)
public:
	bool publish_current() {
		return publish(get_viewport());
	}

	bool publish(const Viewport *viewport) {
		if (!viewport) {
			return false;
		}

		const Camera3D *camera = viewport->get_camera_3d();
		if (!camera) {
			return false;
		}

		const Size2i size = viewport->get_texture()->get_size();
		cameraInfo.width() = size.width;
		cameraInfo.height() = size.height;
		constexpr static double DEG_TO_RAD = 3.141592653589793238463 / 180.0;
		const real_t fov = camera->get_fov() * DEG_TO_RAD;
		const Camera3D::KeepAspect keepAspect = camera->get_keep_aspect_mode();

		double f;
		if (keepAspect == Camera3D::KeepAspect::KEEP_WIDTH) {
			f = double(size.width) / (2.0 * tan(fov / 2.0));
		} else {
			f = double(size.height) / (2.0 * tan(fov / 2.0));
		}

		cameraInfo.k()[0] = cameraInfo.k()[4] = f;
		cameraInfo.k()[2] = double(size.width) / 2.0;
		cameraInfo.k()[5] = double(size.height / 2.0);
		cameraInfo.k()[1] = cameraInfo.k()[3] = cameraInfo.k()[6] = cameraInfo.k()[7] = 0.0;
		cameraInfo.k()[8] = 1.0;
		return _publish(&cameraInfo);
	}

	enum Distortion {
		PLUMB_BOB,
		RATIONAL_POLYNOMIAL,
		EQUIDISTANT
	};

	Distortion distortion;

	void set_distortion(Distortion p_distortion, PackedFloat32Array p_coefficients) {
		switch (p_distortion) {
			case Distortion::PLUMB_BOB:
				cameraInfo.distortion_model() = sensor_msgs::distortion_models::PLUMB_BOB;
				break;

			case Distortion::RATIONAL_POLYNOMIAL:
				cameraInfo.distortion_model() = sensor_msgs::distortion_models::RATIONAL_POLYNOMIAL;
				break;

			case Distortion::EQUIDISTANT:
				cameraInfo.distortion_model() = sensor_msgs::distortion_models::EQUIDISTANT;
				break;
		}

		cameraInfo.d().resize(p_coefficients.size());
		for (size_t i = 0; i < cameraInfo.d().size(); i++) {
			cameraInfo.d()[i] = static_cast<double>(p_coefficients[i]);
		}
	}

	Distortion get_distortion() { return distortion; }

protected:
	static void _bind_methods() {
		BIND_ENUM_CONSTANT(PLUMB_BOB);
		BIND_ENUM_CONSTANT(RATIONAL_POLYNOMIAL);
		BIND_ENUM_CONSTANT(EQUIDISTANT);

		ClassDB::bind_method(D_METHOD("set_distortion", "distortion", "coefficients"), &CameraInfoPublisher::set_distortion);
		ClassDB::bind_method(D_METHOD("get_distortion"), &CameraInfoPublisher::get_distortion);
		ADD_PROPERTY(PropertyInfo(Variant::INT, "distortion", PROPERTY_HINT_ENUM, "PLUMB_BOB,RATIONAL_POLYNOMIAL,EQUIDISTANT"), "", "get_distortion");
		ClassDB::bind_method(D_METHOD("publish", "viewport"), &CameraInfoPublisher::publish);
		ClassDB::bind_method(D_METHOD("publish_current"), &CameraInfoPublisher::publish_current);
	}

private:
	sensor_msgs::msg::CameraInfo cameraInfo{};
	eprosima::fastdds::dds::TypeSupport _set_type() override {
		return eprosima::fastdds::dds::TypeSupport(new sensor_msgs::msg::CameraInfoPubSubType());
	}
};

VARIANT_ENUM_CAST(CameraInfoPublisher::Distortion);