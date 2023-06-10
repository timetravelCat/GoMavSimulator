#pragma once

#include "publisher.h"
#include "sensor_msgs/fill_image.hpp"
#include "sensor_msgs/image_encodings.hpp"
#include "sensor_msgs/msg/ImagePubSubTypes.h"
#include <godot_cpp/classes/image.hpp>

using namespace godot;

class ImagePublisher : public Publisher {
	GDCLASS(ImagePublisher, Publisher)
public:
	const char *get_encoding(Image::Format format) {
		switch (format) {
			case Image::Format::FORMAT_L8: //luminance
				return sensor_msgs::image_encodings::MONO8;
			case Image::Format::FORMAT_LA8: //luminance-alpha
				return sensor_msgs::image_encodings::TYPE_8UC2;
			case Image::Format::FORMAT_R8:
				return sensor_msgs::image_encodings::MONO8;
			case Image::Format::FORMAT_RG8:
				return sensor_msgs::image_encodings::TYPE_8UC2;
			case Image::Format::FORMAT_RGB8:
				return sensor_msgs::image_encodings::RGB8;
			case Image::Format::FORMAT_RGBA8:
				return sensor_msgs::image_encodings::RGBA8;
			case Image::Format::FORMAT_RGBA4444:
				return sensor_msgs::image_encodings::TYPE_8UC2;
			case Image::Format::FORMAT_RGB565:
				return sensor_msgs::image_encodings::TYPE_8UC2;
			case Image::Format::FORMAT_RF: //float
				return sensor_msgs::image_encodings::TYPE_32FC1;
			case Image::Format::FORMAT_RGF:
				return sensor_msgs::image_encodings::TYPE_32FC2;
			case Image::Format::FORMAT_RGBF:
				return sensor_msgs::image_encodings::TYPE_32FC3;
			case Image::Format::FORMAT_RGBAF:
				return sensor_msgs::image_encodings::TYPE_32FC4;
			case Image::Format::FORMAT_RH: //half float
				return sensor_msgs::image_encodings::TYPE_16SC1;
			case Image::Format::FORMAT_RGH:
				return sensor_msgs::image_encodings::TYPE_16SC2;
			case Image::Format::FORMAT_RGBH:
				return sensor_msgs::image_encodings::TYPE_16SC3;
			case Image::Format::FORMAT_RGBAH:
				return sensor_msgs::image_encodings::TYPE_16SC4;
			case Image::Format::FORMAT_RGBE9995:
				return sensor_msgs::image_encodings::TYPE_32SC1;
			case Image::Format::FORMAT_DXT1: //s3tc bc1
			case Image::Format::FORMAT_DXT3: //bc2
			case Image::Format::FORMAT_DXT5: //bc3
			case Image::Format::FORMAT_RGTC_R:
			case Image::Format::FORMAT_RGTC_RG:
			case Image::Format::FORMAT_BPTC_RGBA: //btpc bc7
			case Image::Format::FORMAT_BPTC_RGBF: //float bc6h
			case Image::Format::FORMAT_BPTC_RGBFU: //unsigned float bc6hu
			case Image::Format::FORMAT_ETC: //etc1
			case Image::Format::FORMAT_ETC2_R11: //etc2
			case Image::Format::FORMAT_ETC2_R11S: //signed, NOT srgb.
			case Image::Format::FORMAT_ETC2_RG11:
			case Image::Format::FORMAT_ETC2_RG11S:
			case Image::Format::FORMAT_ETC2_RGB8:
			case Image::Format::FORMAT_ETC2_RGBA8:
			case Image::Format::FORMAT_ETC2_RGB8A1:
			case Image::Format::FORMAT_ETC2_RA_AS_RG: //used to make basis universal happy
			case Image::Format::FORMAT_DXT5_RA_AS_RG: //used to make basis universal happy
			case Image::Format::FORMAT_ASTC_4x4:
			case Image::Format::FORMAT_ASTC_4x4_HDR:
			case Image::Format::FORMAT_ASTC_8x8:
			case Image::Format::FORMAT_ASTC_8x8_HDR:
			case Image::Format::FORMAT_MAX:
				return "UNKNOWN";
		}

		return "UNKNOWN";
	}

	bool publish(const Ref<Image> &p_image) {
		const std::string encoding = get_encoding(p_image->get_format());
		if (encoding.compare("UNKNOWN") == 0) {
			WARN_PRINT_ONCE("Cannot publish compressed image type in ImagePublisher");
			return false;
		}
		const int num_channels = sensor_msgs::image_encodings::numChannels(encoding);
		// const int bit_depth = sensor_msgs::image_encodings::bitDepth(encoding);

		sensor_msgs::fillImage(
				image,
				encoding,
				p_image->get_height(),
				p_image->get_width(),
				num_channels * p_image->get_width(),
				p_image->get_data().ptr());

		updateHeader(image);
		return _publish(&image);
	}

protected:
	static void _bind_methods() {
		ClassDB::bind_method(D_METHOD("publish", "image"), &ImagePublisher::publish);
	}

private:
	sensor_msgs::msg::Image image{};
	eprosima::fastdds::dds::TypeSupport _set_type() override {
		return eprosima::fastdds::dds::TypeSupport(new sensor_msgs::msg::ImagePubSubType());
	}
};