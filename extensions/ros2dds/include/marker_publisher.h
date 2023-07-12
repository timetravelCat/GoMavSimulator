
#pragma once

#include "publisher.h"
#include "visualization_msgs/msg/MarkerPubSubTypes.h"

#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/mesh.hpp>
#include <godot_cpp/classes/primitive_mesh.hpp>
#include <godot_cpp/classes/box_mesh.hpp>
#include <godot_cpp/classes/cylinder_mesh.hpp>
#include <godot_cpp/classes/plane_mesh.hpp>
#include <godot_cpp/classes/sphere_mesh.hpp>
#include <godot_cpp/classes/quad_mesh.hpp>
#include <godot_cpp/classes/point_mesh.hpp>
#include <godot_cpp/classes/text_mesh.hpp>
#include <godot_cpp/classes/standard_material3d.hpp>
#include <godot_cpp/classes/mesh_instance3d.hpp>
#include <godot_cpp/classes/random_number_generator.hpp>
#include <godot_cpp/classes/mesh_data_tool.hpp>
#include <godot_cpp/classes/array_mesh.hpp>

using namespace godot;

class MarkerPublisher : public Publisher
{
	GDCLASS(MarkerPublisher, Publisher)

public:
	enum TYPE
	{
		ARROW = visualization_msgs::msg::Marker_Constants::ARROW,
		CUBE = visualization_msgs::msg::Marker_Constants::CUBE,
		SPHERE = visualization_msgs::msg::Marker_Constants::SPHERE,
		CYLINDER = visualization_msgs::msg::Marker_Constants::CYLINDER,
		LINE_STRIP = visualization_msgs::msg::Marker_Constants::LINE_STRIP,
		LINE_LIST = visualization_msgs::msg::Marker_Constants::LINE_LIST,
		CUBE_LIST = visualization_msgs::msg::Marker_Constants::CUBE_LIST,
		SPHERE_LIST = visualization_msgs::msg::Marker_Constants::SPHERE_LIST,
		POINTS = visualization_msgs::msg::Marker_Constants::POINTS,
		TEXT_VIEW_FACING = visualization_msgs::msg::Marker_Constants::TEXT_VIEW_FACING,
		TRIANGLE_LIST = visualization_msgs::msg::Marker_Constants::TRIANGLE_LIST,
	};

	TYPE type{ARROW};
	void set_type(TYPE p_type) { type = p_type; };
	TYPE get_type() { return type; };

	enum Action
	{
		ADD = visualization_msgs::msg::Marker_Constants::ADD,
		MODIFIY = visualization_msgs::msg::Marker_Constants::MODIFY,
		DELETE = visualization_msgs::msg::Marker_Constants::DELETE,
		DELETEALL = visualization_msgs::msg::Marker_Constants::DELETEALL
	};

	Action action{Action::MODIFIY};
	void set_action(Action p_action) { action = p_action; };
	Action get_action() { return action; };

	Ref<Mesh> mesh{nullptr};
	void set_mesh(const Ref<Mesh> p_mesh)
	{
		mesh = p_mesh;
		if (mesh.is_null())
		{
			return;
		}

		Ref<Material> material;
		if (cast_to<BoxMesh>(mesh.ptr()))
		{
			BoxMesh *boxMesh = cast_to<BoxMesh>(mesh.ptr());
			material = boxMesh->get_material();
			set_scale(boxMesh->get_size());
			type = CUBE;
		}
		else if (cast_to<CylinderMesh>(mesh.ptr()))
		{
			CylinderMesh *cylinderMesh = cast_to<CylinderMesh>(mesh.ptr());
			material = cylinderMesh->get_material();
			// TODO set_scale not working
			set_scale(Vector3{2.0f * (real_t)cylinderMesh->get_top_radius(), 2.0f * (real_t)cylinderMesh->get_top_radius(), (real_t)cylinderMesh->get_height()});
			type = CYLINDER;
		}
		else if (cast_to<PlaneMesh>(mesh.ptr()))
		{
			PlaneMesh *planeMesh = cast_to<PlaneMesh>(mesh.ptr());
			material = planeMesh->get_material();
			Vector3 size;
			switch (planeMesh->get_orientation())
			{
			case PlaneMesh::Orientation::FACE_X:
				size = Vector3{0.0f, planeMesh->get_size().y, planeMesh->get_size().x};
				break;
			case PlaneMesh::Orientation::FACE_Y:
				size = Vector3{planeMesh->get_size().x, 0.0f, planeMesh->get_size().y};
				break;
			case PlaneMesh::Orientation::FACE_Z:
				size = Vector3{planeMesh->get_size().x, planeMesh->get_size().y, 0.0f};
				break;
			}

			if (eus_to_enu)
			{
				set_scale(ENU2EUS::eus_to_enu_v(size));
			}
			else
			{
				set_scale(size);
			}

			type = CUBE;
		}
		else if (cast_to<QuadMesh>(mesh.ptr()))
		{
			QuadMesh *quadMesh = cast_to<QuadMesh>(mesh.ptr());
			material = quadMesh->get_material();
			Vector3 size;
			switch (quadMesh->get_orientation())
			{
			case QuadMesh::Orientation::FACE_X:
				size = Vector3{0.0f, quadMesh->get_size().y, quadMesh->get_size().x};
				break;
			case QuadMesh::Orientation::FACE_Y:
				size = Vector3{quadMesh->get_size().x, 0.0f, quadMesh->get_size().y};
				break;
			case QuadMesh::Orientation::FACE_Z:
				size = Vector3{quadMesh->get_size().x, quadMesh->get_size().y, 0.0f};
				break;
			}

			if (eus_to_enu)
			{
				set_scale(ENU2EUS::eus_to_enu_v(size));
			}
			else
			{
				set_scale(size);
			}

			type = CUBE;
		}
		else if (cast_to<SphereMesh>(mesh.ptr()))
		{
			SphereMesh *sphereMesh = cast_to<SphereMesh>(mesh.ptr());
			material = sphereMesh->get_material();
			set_scale(Vector3{2.0f * (real_t)sphereMesh->get_radius(), 2.0f * (real_t)sphereMesh->get_radius(), (real_t)sphereMesh->get_height()});
			type = SPHERE;
		}
		else if (cast_to<PointMesh>(mesh.ptr()))
		{
			PointMesh *pointMesh = cast_to<PointMesh>(mesh.ptr());
			material = pointMesh->get_material();
			type = POINTS;
		}
		else if (cast_to<TextMesh>(mesh.ptr()))
		{
			TextMesh *textMesh = cast_to<TextMesh>(mesh.ptr());
			material = textMesh->get_material();
			set_text(textMesh->get_text());
			set_scale(Vector3{1.0f, 1.0f, float(textMesh->get_font_size()) / 16.0f});
			type = TEXT_VIEW_FACING;
		}
		else
		{
			type = TYPE::TRIANGLE_LIST;
			PackedVector3Array faces = mesh->get_faces();
			marker.points().resize(faces.size());
			marker.colors().resize(faces.size());
			if (eus_to_enu)
			{
				for (int i = 0; i < faces.size(); i++)
				{
					marker.points()[i] = conversion(ENU2EUS::eus_to_enu_v(faces[i]));
				}
			}
			else
			{
				for (int i = 0; i < faces.size(); i++)
				{
					marker.points()[i] = conversion(faces[i]);
				}
			}
		}

		if (material.is_valid())
		{
			StandardMaterial3D *standardMaterial = cast_to<StandardMaterial3D>(material.ptr());
			if (standardMaterial)
			{
				set_color(standardMaterial->get_albedo());
			}
		}
	}
	Ref<Mesh> get_mesh() const { return mesh; };

	Node *surface = nullptr;
	void set_surface(Node *p_surface)
	{
		if (surface == p_surface)
		{
			return;
		}

		marker.points().resize(0);
		marker.colors().resize(0);

		if(p_surface){
			type = TYPE::TRIANGLE_LIST;
			recurve_surface_update(p_surface);	
		}

		surface = p_surface;
	}
	Node *get_surface() { return surface; }

	RandomNumberGenerator rng;

	void recurve_surface_update(Node *_child, Transform3D _transform = Transform3D())
	{
		Node3D *_node_3d = cast_to<Node3D>(_child);
		if (_node_3d)
		{
			_transform.basis = _transform.basis*_node_3d->get_basis();
			_transform.origin = _transform.origin + _transform.basis.xform(_node_3d->get_position());
		}

		MeshInstance3D *_mesh_instance_3d = cast_to<MeshInstance3D>(_child);
		if (_mesh_instance_3d)
		{
			Ref<Mesh> mesh = _mesh_instance_3d->get_mesh();
			std_msgs::msg::ColorRGBA color;
			if (mesh.is_valid())
			{
				PackedVector3Array faces = mesh->get_faces();
				if (eus_to_enu)
				{
					for (int i = 0; i < faces.size(); i++)
					{
						Vector3 vertex = _transform.basis.xform(faces[i]) + _transform.origin;
						marker.points().push_back(conversion(ENU2EUS::eus_to_enu_v(vertex)));
						color.r() = rng.randf();
						color.g() = rng.randf();
						color.b() = rng.randf();
						color.a() = 1.0f;
						marker.colors().push_back(color);
					}
				}
				else
				{
					for (int i = 0; i < faces.size(); i++)
					{
						Vector3 vertex = _transform.basis.xform(faces[i]) + _transform.origin;
						marker.points().push_back(conversion(vertex));
						color.r() = rng.randf();
						color.g() = rng.randf();
						color.b() = rng.randf();
						color.a() = 1.0f;
						marker.colors().push_back(color);
					}
				}
			}
		}

		for (int i = 0; i < _child->get_child_count(); i++)
		{
			recurve_surface_update(_child->get_child(i), _transform);
		}
	}

	void set_eus_to_enu(bool p_eus_to_enu) { eus_to_enu = p_eus_to_enu; };
	bool get_eus_to_enu() { return eus_to_enu; };
	bool eus_to_enu{true};

	void set_id(int32_t p_id) { id = p_id; };
	int32_t get_id() { return id; };
	int32_t id{0};

	void set_frame_locked(bool p_frame_locked) { frame_locked = p_frame_locked; };
	bool get_frame_locked() { return frame_locked; };
	bool frame_locked{false};

	void set_lifetime(float p_lifetime) { lifetime = p_lifetime; };
	float get_lifetime() { return lifetime; };
	float lifetime{0.0f};

	void set_ns(String p_ns) { ns = p_ns; };
	String get_ns() { return ns; };
	String ns{""};

	void set_text(String p_text)
	{
		text = p_text;
		type = TYPE::TEXT_VIEW_FACING;
	};
	String get_text() { return text; };
	String text{""};

	bool publish(Vector3 position, Quaternion orientation)
	{
		updateHeader(marker);
		if (type == LINE_STRIP ||
			type == LINE_LIST ||
			type == CUBE_LIST ||
			type == SPHERE_LIST ||
			type == POINTS)
		{
			WARN_PRINT_ONCE("Use publish_list instead of publish");
			return false;
		}

		if (eus_to_enu)
		{
			position = ENU2EUS::eus_to_enu_v(position);
			orientation = ENU2EUS::eus_to_enu_q(orientation);
		}

		marker.type((int32_t)type);
		marker.action((int32_t)action);
		marker.id(id);
		marker.scale(conversion_v(scale));
		marker.color().r(color.r);
		marker.color().g(color.g);
		marker.color().b(color.b);
		marker.color().a(color.a);

		marker.frame_locked(frame_locked);
		marker.lifetime().sec() = (int32_t)lifetime;
		marker.lifetime().nanosec() = (lifetime - float(marker.lifetime().sec())) * 1000000000;
		marker.ns(ns.utf8().get_data());
		marker.text(get_text().utf8().get_data());
		marker.pose().position(conversion(position));
		marker.pose().orientation(conversion(orientation));
		return _publish(&marker);
	}

	bool publish_list(const PackedVector3Array &positions, const PackedColorArray &colors)
	{
		updateHeader(marker);

		if (type == ARROW ||
			type == CUBE ||
			type == SPHERE ||
			type == CYLINDER ||
			type == TEXT_VIEW_FACING)
		{
			WARN_PRINT_ONCE("Use publish instead of publish_list");
			return false;
		}

		if (mesh.is_valid())
		{
			set_mesh(mesh);
		}

		marker.points().resize(positions.size());
		if (eus_to_enu)
		{
			for (int i = 0; i < positions.size(); i++)
			{
				marker.points()[i] = conversion(ENU2EUS::eus_to_enu_v(positions[i]));
			}
		}
		else
		{
			for (int i = 0; i < positions.size(); i++)
			{
				marker.points()[i] = conversion(positions[i]);
			}
		}

		if (positions.size() == colors.size())
		{
			marker.colors().resize(colors.size());
			for (int i = 0; i < colors.size(); i++)
			{
				marker.colors()[i].r(colors[i].r);
				marker.colors()[i].g(colors[i].g);
				marker.colors()[i].b(colors[i].b);
				marker.colors()[i].a(colors[i].a);
			}
		}

		marker.type((int32_t)type);
		marker.action((int32_t)action);
		marker.id(id);
		marker.scale(conversion_v(scale));
		marker.color().r(color.r);
		marker.color().g(color.g);
		marker.color().b(color.b);
		marker.color().a(color.a);
		marker.frame_locked(frame_locked);
		marker.text(get_text().utf8().get_data());
		marker.lifetime().sec() = (int32_t)lifetime;
		marker.lifetime().nanosec() = (lifetime - float(marker.lifetime().sec())) * 1000000000;
		marker.ns(ns.utf8().get_data());
		return _publish(&marker);
	}

	void set_color(Color p_color) { color = p_color; };
	Color get_color() { return color; };
	Color color;

	void set_scale(Vector3 p_scale) { scale = p_scale; };
	Vector3 get_scale() { return scale; };
	Vector3 scale{1.0f, 1.0f, 1.0f};

	Node3D *node3d{nullptr};
	void set_node3d(Node3D *p_node3d)
	{
		if (node3d == p_node3d)
		{
			return;
		}
		node3d = p_node3d;
	}
	Node3D *get_node3d() { return node3d; }

	bool global{true};
	void set_global(bool p_global) { global = p_global; }
	bool get_global() { return global; }

	bool publish_node3d()
	{
		if (node3d == nullptr)
			return false;

		Vector3 position;
		Quaternion orientation;
		if (global)
		{
			position = node3d->get_global_position();
			orientation = node3d->get_global_transform().get_basis().get_quaternion();
		}
		else
		{
			position = node3d->get_position();
			orientation = node3d->get_transform().get_basis().get_quaternion();
		}

		if (type == POINTS)
		{
			PackedVector3Array positionArray;
			positionArray.push_back(position);
			return publish_list(positionArray, PackedColorArray{});
		}

		return publish(position, orientation);
	}

protected:
	static void _bind_methods()
	{
		BIND_ENUM_CONSTANT(ADD);
		BIND_ENUM_CONSTANT(MODIFIY);
		BIND_ENUM_CONSTANT(DELETE);
		BIND_ENUM_CONSTANT(DELETEALL);

		BIND_ENUM_CONSTANT(ARROW);
		BIND_ENUM_CONSTANT(CUBE);
		BIND_ENUM_CONSTANT(SPHERE);
		BIND_ENUM_CONSTANT(CYLINDER);
		BIND_ENUM_CONSTANT(LINE_STRIP);
		BIND_ENUM_CONSTANT(LINE_LIST);
		BIND_ENUM_CONSTANT(CUBE_LIST);
		BIND_ENUM_CONSTANT(SPHERE_LIST);
		BIND_ENUM_CONSTANT(POINTS);
		BIND_ENUM_CONSTANT(TEXT_VIEW_FACING);
		BIND_ENUM_CONSTANT(TRIANGLE_LIST);

		ClassDB::bind_method(D_METHOD("set_type", "type"), &MarkerPublisher::set_type);
		ClassDB::bind_method(D_METHOD("get_type"), &MarkerPublisher::get_type);
		ADD_PROPERTY(PropertyInfo(Variant::INT, "type", PROPERTY_HINT_ENUM, "ARROW,CUBE,SPHERE,CYLINDER,LINE_STRIP,LINE_LIST,CUBE_LIST,SPHERE_LIST,POINTS,TEXT_VIEW_FACING,TRIANGLE_LIST"), "set_type", "get_type");

		ClassDB::bind_method(D_METHOD("set_action", "action"), &MarkerPublisher::set_action);
		ClassDB::bind_method(D_METHOD("get_action"), &MarkerPublisher::get_action);
		ADD_PROPERTY(PropertyInfo(Variant::INT, "action", PROPERTY_HINT_ENUM, "Add,Modify,Delete,DeletAll"), "set_action", "get_action");

		ClassDB::bind_method(D_METHOD("set_mesh", "mesh"), &MarkerPublisher::set_mesh);
		ClassDB::bind_method(D_METHOD("get_mesh"), &MarkerPublisher::get_mesh);
		ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "mesh", PROPERTY_HINT_RESOURCE_TYPE, "Mesh"), "set_mesh", "get_mesh");

		ClassDB::bind_method(D_METHOD("set_eus_to_enu", "eus_to_enu"), &MarkerPublisher::set_eus_to_enu);
		ClassDB::bind_method(D_METHOD("get_eus_to_enu"), &MarkerPublisher::get_eus_to_enu);
		ADD_PROPERTY(PropertyInfo(Variant::BOOL, "eus_to_enu"), "set_eus_to_enu", "get_eus_to_enu");

		ClassDB::bind_method(D_METHOD("set_id", "id"), &MarkerPublisher::set_id);
		ClassDB::bind_method(D_METHOD("get_id"), &MarkerPublisher::get_id);
		ADD_PROPERTY(PropertyInfo(Variant::INT, "id"), "set_id", "get_id");

		ClassDB::bind_method(D_METHOD("set_frame_locked", "frame_locked"), &MarkerPublisher::set_frame_locked);
		ClassDB::bind_method(D_METHOD("get_frame_locked"), &MarkerPublisher::get_frame_locked);
		ADD_PROPERTY(PropertyInfo(Variant::BOOL, "frame_locked"), "set_frame_locked", "get_frame_locked");

		ClassDB::bind_method(D_METHOD("set_lifetime", "lifetime"), &MarkerPublisher::set_lifetime);
		ClassDB::bind_method(D_METHOD("get_lifetime"), &MarkerPublisher::get_lifetime);
		ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "lifetime"), "set_lifetime", "get_lifetime");

		ClassDB::bind_method(D_METHOD("set_ns", "ns"), &MarkerPublisher::set_ns);
		ClassDB::bind_method(D_METHOD("get_ns"), &MarkerPublisher::get_ns);
		ADD_PROPERTY(PropertyInfo(Variant::STRING, "ns"), "set_ns", "get_ns");

		ClassDB::bind_method(D_METHOD("set_text", "text"), &MarkerPublisher::set_text);
		ClassDB::bind_method(D_METHOD("get_text"), &MarkerPublisher::get_text);
		ADD_PROPERTY(PropertyInfo(Variant::STRING, "text"), "set_text", "get_text");

		ClassDB::bind_method(D_METHOD("set_scale", "scale"), &MarkerPublisher::set_scale);
		ClassDB::bind_method(D_METHOD("get_scale"), &MarkerPublisher::get_scale);
		ADD_PROPERTY(PropertyInfo(Variant::VECTOR3, "scale"), "set_scale", "get_scale");

		ClassDB::bind_method(D_METHOD("set_color", "color"), &MarkerPublisher::set_color);
		ClassDB::bind_method(D_METHOD("get_color"), &MarkerPublisher::get_color);
		ADD_PROPERTY(PropertyInfo(Variant::COLOR, "color"), "set_color", "get_color");

		ClassDB::bind_method(D_METHOD("publish", "position", "orientation"), &MarkerPublisher::publish);

		ClassDB::bind_method(D_METHOD("set_surface", "surface"), &MarkerPublisher::set_surface);
		ClassDB::bind_method(D_METHOD("get_surface"), &MarkerPublisher::get_surface);
		ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "surface", PROPERTY_HINT_NODE_TYPE, "Node"), "set_surface", "get_surface");

		ClassDB::bind_method(D_METHOD("set_node3d", "node3d"), &MarkerPublisher::set_node3d);
		ClassDB::bind_method(D_METHOD("get_node3d"), &MarkerPublisher::get_node3d);
		ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "node3d", PROPERTY_HINT_NODE_TYPE, "Node3D"), "set_node3d", "get_node3d");

		ClassDB::bind_method(D_METHOD("set_global", "global"), &MarkerPublisher::set_global);
		ClassDB::bind_method(D_METHOD("get_global"), &MarkerPublisher::get_global);
		ADD_PROPERTY(PropertyInfo(Variant::BOOL, "global"), "set_global", "get_global");
		ClassDB::bind_method(D_METHOD("publish_node3d"), &MarkerPublisher::publish_node3d);
	}

private:
	visualization_msgs::msg::Marker marker{};
	eprosima::fastdds::dds::TypeSupport _set_type() override
	{
		return eprosima::fastdds::dds::TypeSupport(new visualization_msgs::msg::MarkerPubSubType());
	}
};

VARIANT_ENUM_CAST(MarkerPublisher::Action);
VARIANT_ENUM_CAST(MarkerPublisher::TYPE);