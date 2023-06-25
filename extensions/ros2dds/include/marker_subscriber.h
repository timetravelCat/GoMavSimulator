#pragma once

#include "conversion.h"
#include <godot_cpp/classes/mesh_instance3d.hpp>
#include "subscriber.h"
#include "visualization_msgs/msg/MarkerPubSubTypes.h"
#include <godot_cpp/classes/box_mesh.hpp>
#include <godot_cpp/classes/primitive_mesh.hpp>
#include <godot_cpp/classes/cylinder_mesh.hpp>
#include <godot_cpp/classes/plane_mesh.hpp>
#include <godot_cpp/classes/sphere_mesh.hpp>
#include <godot_cpp/classes/quad_mesh.hpp>
#include <godot_cpp/classes/point_mesh.hpp>
#include <godot_cpp/classes/text_mesh.hpp>
#include <godot_cpp/classes/standard_material3d.hpp>

using namespace godot;

class MarkerSubscriber : public Subscriber {
	GDCLASS(MarkerSubscriber, Subscriber)
public:
	MarkerSubscriber() {
		meshInstance3D = memnew(MeshInstance3D);
	}
	~MarkerSubscriber() {
		memdelete(meshInstance3D);
	}

	void _on_data_subscribed(void *p_data) override {
		if (!meshInstance3D->get_parent()) {
			call_deferred("add_child", meshInstance3D);
		}

		const visualization_msgs::msg::Marker *recv = static_cast<visualization_msgs::msg::Marker *>(p_data);
		if (mesh_automatic) {
			switch (recv->type()) {
				case visualization_msgs::msg::Marker_Constants::CUBE: {
					BoxMesh *boxMesh = memnew(BoxMesh);
					meshInstance3D->set_mesh(boxMesh);
					boxMesh->set_size(conversion(recv->scale()));
					break;
				}
				case visualization_msgs::msg::Marker_Constants::SPHERE: {
					SphereMesh *sphereMesh = memnew(SphereMesh);
					meshInstance3D->set_mesh(sphereMesh);
					sphereMesh->set_height(recv->scale().z());
					sphereMesh->set_radius(recv->scale().x() / 2.0f);
					break;
				}
				case visualization_msgs::msg::Marker_Constants::CYLINDER: {
					CylinderMesh *cylinderMesh = memnew(CylinderMesh);
					meshInstance3D->set_mesh(cylinderMesh);
					cylinderMesh->set_height(recv->scale().z());
					cylinderMesh->set_top_radius(recv->scale().x() / 2.0f);
					break;
				}
				case visualization_msgs::msg::Marker_Constants::POINTS: {
					PointMesh *pointMesh = memnew(PointMesh);
					meshInstance3D->set_mesh(pointMesh);
					break;
				}
				case visualization_msgs::msg::Marker_Constants::TEXT_VIEW_FACING: {
					TextMesh *textMesh = memnew(TextMesh);
					meshInstance3D->set_mesh(textMesh);
					textMesh->set_font_size(int(recv->scale().z() * 16.0f));
					break;
				}
				default:
					break;
			}
		}

		TextMesh *textMesh = cast_to<TextMesh>(meshInstance3D->get_mesh().ptr());
		if (textMesh) {
			textMesh->set_text(String{ recv->text().c_str() });
		}

		PrimitiveMesh *primitiveMesh = cast_to<PrimitiveMesh>(meshInstance3D->get_mesh().ptr());
		if (mesh_automatic && primitiveMesh) {
			if (primitiveMesh->get_material().is_null() || !cast_to<StandardMaterial3D>(primitiveMesh->get_material().ptr())) {
				primitiveMesh->set_material(memnew(StandardMaterial3D));
			}

			StandardMaterial3D *material = cast_to<StandardMaterial3D>(primitiveMesh->get_material().ptr());
			material->set_albedo(Color{ recv->color().r(), recv->color().g(), recv->color().b(), recv->color().a() });
		}

		if (enu_to_eus) {
			if (global) {
				meshInstance3D->set_global_transform(Transform3D{ Basis{ ENU2EUS::enu_to_eus_q(conversion(recv->pose().orientation())) },
						ENU2EUS::enu_to_eus_v(conversion(recv->pose().position())) });
			} else {
				meshInstance3D->set_transform(Transform3D{ Basis{ ENU2EUS::enu_to_eus_q(conversion(recv->pose().orientation())) },
						ENU2EUS::enu_to_eus_v(conversion(recv->pose().position())) });
			}
		} else {
			if (global) {
				meshInstance3D->set_global_transform(Transform3D{ Basis{ conversion(recv->pose().orientation()) },
						conversion(recv->pose().position()) });
			} else {
				meshInstance3D->set_transform(Transform3D{ Basis{ conversion(recv->pose().orientation()) },
						conversion(recv->pose().position()) });
			}
		}
	}

	void set_enu_to_eus(bool p_enu_to_eus) { enu_to_eus = p_enu_to_eus; };
	bool get_enu_to_eus() { return enu_to_eus; };
	bool enu_to_eus{ true };

	bool global{ true };
	void set_global(bool p_global) { global = p_global; }
	bool get_global() { return global; }

	bool mesh_automatic{ true };
	MeshInstance3D *meshInstance3D{ nullptr };
	void set_mesh(const Ref<Mesh> p_mesh) {
		p_mesh.is_valid() ? mesh_automatic = false : mesh_automatic = true;
		meshInstance3D->set_mesh(p_mesh);
		if (!meshInstance3D->get_parent()) {
			call_deferred("add_child", meshInstance3D);
		}
	}
	Ref<Mesh> get_mesh() const { return meshInstance3D->get_mesh(); };

protected:
	static void _bind_methods() {
		ClassDB::bind_method(D_METHOD("set_enu_to_eus", "enu_to_eus"), &MarkerSubscriber::set_enu_to_eus);
		ClassDB::bind_method(D_METHOD("get_enu_to_eus"), &MarkerSubscriber::get_enu_to_eus);
		ADD_PROPERTY(PropertyInfo(Variant::BOOL, "enu_to_eus"), "set_enu_to_eus", "get_enu_to_eus");

		ClassDB::bind_method(D_METHOD("set_global", "global"), &MarkerSubscriber::set_global);
		ClassDB::bind_method(D_METHOD("get_global"), &MarkerSubscriber::get_global);
		ADD_PROPERTY(PropertyInfo(Variant::BOOL, "global"), "set_global", "get_global");

		ClassDB::bind_method(D_METHOD("set_mesh", "mesh"), &MarkerSubscriber::set_mesh);
		ClassDB::bind_method(D_METHOD("get_mesh"), &MarkerSubscriber::get_mesh);
		ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "mesh", PROPERTY_HINT_RESOURCE_TYPE, "Mesh"), "set_mesh", "get_mesh");
	}

private:
	eprosima::fastdds::dds::TypeSupport _set_type() override {
		return eprosima::fastdds::dds::TypeSupport(new visualization_msgs::msg::MarkerPubSubType());
	}
};