#pragma once

#include "publisher.h"
#include "sensor_msgs/fill_image.hpp"
#include "sensor_msgs/image_encodings.hpp"
#include "sensor_msgs/msg/CompressedImagePubSubTypes.h"
#include <godot_cpp/classes/image.hpp>

using namespace godot;

class CompressedImagePublisher : public Publisher {
	GDCLASS(CompressedImagePublisher, Publisher)
public:
	enum Format {
		PNG,
		JPEG
	};

	bool publish() {
		const Ref<Image> p_image = get_viewport()->get_texture()->get_image();
		compressedImage.format() = format == PNG ? "png" : "jpeg";
		switch (format) {
			case JPEG: {
				copy(p_image->save_jpg_to_buffer(quality));
			} break;
			default:
			case PNG: {
				copy(p_image->save_png_to_buffer());
			} break;
		}

		updateHeader(compressedImage);
		return _publish(&compressedImage);
	}

	void set_format(Format p_format) { format = p_format; };
	bool get_format() { return format; };
	Format format{ PNG };

	void set_quality(float p_quality) { quality = p_quality; };
	float get_quality() { return quality; };
	float quality{ 0.75f };

protected:
	static void _bind_methods() {
		BIND_ENUM_CONSTANT(JPEG);
		BIND_ENUM_CONSTANT(PNG);

		ClassDB::bind_method(D_METHOD("publish"), &CompressedImagePublisher::publish);
		ClassDB::bind_method(D_METHOD("set_format", "format"), &CompressedImagePublisher::set_format);
		ClassDB::bind_method(D_METHOD("get_format"), &CompressedImagePublisher::get_format);
		ClassDB::bind_method(D_METHOD("set_quality", "quality"), &CompressedImagePublisher::set_quality);
		ClassDB::bind_method(D_METHOD("get_quality"), &CompressedImagePublisher::get_quality);
		ADD_PROPERTY(PropertyInfo(Variant::INT, "format", PROPERTY_HINT_ENUM, "PNG,JPEG"), "set_format", "get_format");
        ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "quality", PROPERTY_HINT_RANGE, "0,1,0.01"), "set_quality", "get_quality");
	}

	void copy(const PackedByteArray &compressed) {
		compressedImage.data().resize(compressed.size());
		memcpy(compressedImage.data().data(), compressed.ptr(), compressed.size());
	}

private:
	sensor_msgs::msg::CompressedImage compressedImage{};
	eprosima::fastdds::dds::TypeSupport _set_type() override {
		return eprosima::fastdds::dds::TypeSupport(new sensor_msgs::msg::CompressedImagePubSubType());
	}
};

VARIANT_ENUM_CAST(CompressedImagePublisher::Format);