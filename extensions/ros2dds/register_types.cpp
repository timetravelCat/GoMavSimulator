/**************************************************************************/
/*  register_types.cpp                                                    */
/**************************************************************************/
/*                         This file is part of:                          */
/*                             GODOT ENGINE                               */
/*                        https://godotengine.org                         */
/**************************************************************************/
/* Copyright (c) 2014-present Godot Engine contributors (see AUTHORS.md). */
/* Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.                  */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/

#include <gdextension_interface.h>
#include <camera_info_publisher.h>
#include <compressed_image_publisher.h>
#include <coordinate_3d.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/godot.hpp>
#include <image_publisher.h>
#include <marker_publisher.h>
#include <marker_subscriber.h>
#include <path_publisher.h>
#include <path_subscriber.h>
#include <point_cloud_publisher.h>
#include <point_cloud_subscriber.h>
#include <point_stamped_publisher.h>
#include <point_stamped_subscriber.h>
#include <pose_stamped_publisher.h>
#include <pose_stamped_subscriber.h>
#include <publisher.h>
#include <range_publisher.h>
#include <ros2dds.h>
#include <subscriber.h>

static Coordinate3D *_coordinate_3d = nullptr;

void initialize_ros2dds_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}

	GDREGISTER_CLASS(Coordinate3D);
	_coordinate_3d = memnew(Coordinate3D);
	Engine::get_singleton()->register_singleton("Coordinate3D", Coordinate3D::get_singleton());
	GDREGISTER_ABSTRACT_CLASS(ROS2DDS);
	GDREGISTER_ABSTRACT_CLASS(Publisher);
	GDREGISTER_ABSTRACT_CLASS(Subscriber);
	GDREGISTER_CLASS(ImagePublisher);
	GDREGISTER_CLASS(CompressedImagePublisher);
	GDREGISTER_CLASS(CameraInfoPublisher);
	GDREGISTER_CLASS(PoseStampedPublisher);
	GDREGISTER_CLASS(PoseStampedSubscriber);
	GDREGISTER_CLASS(PointStampedPublisher);
	GDREGISTER_CLASS(PointStampedSubscriber);
	GDREGISTER_CLASS(PathPublisher);
	GDREGISTER_CLASS(PathSubscriber);
	GDREGISTER_CLASS(PointCloudPublisher);
	GDREGISTER_CLASS(PointCloudSubscriber);
	GDREGISTER_CLASS(RangePublisher);
	GDREGISTER_CLASS(MarkerPublisher);
	GDREGISTER_CLASS(MarkerSubscriber);
}

void uninitialize_ros2dds_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}

	Engine::get_singleton()->unregister_singleton("Coordinate3D");
	if (_coordinate_3d) {
		memdelete(_coordinate_3d);
	}
}
