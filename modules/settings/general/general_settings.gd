extends Node

var selected_world:int = 0
var world_volumetric = preload("res://modules/world/environment/Volumetric.tscn")

var district_mumbai:PackedScene = preload("res://assets/district/cartoon/mumbai.tscn")
var district_mini:PackedScene = preload("res://assets/district/cartoon/mini.tscn")
# var district_village:PackedScene = preload("res://assets/district/photorealistic/village.tscn")

var viewports:Array

func _enter_tree():
	# TODO implement save-load
	# TODO select by start settings
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	# Register main window viewport
	viewports.append(get_viewport())		
	
	# Regieter world
	var world:Node3D = world_volumetric.instantiate()
	world.name = "world"
	add_child(world)
	
	# Register district
	_district_aa = Vector3.ZERO
	_district_bb = Vector3.ZERO
	var district:Node3D = district_mini.instantiate()
	district.name = "district"
	recursive_create_collision_body(district)
	add_child(district)

func get_current_world() -> WorldEnvironment:
	if find_child("world", false, false):	
		return find_child("world", false, false).get_node("WorldEnvironment")
	return null

var _district_aa:Vector3 = Vector3.INF
var _district_bb:Vector3 = -Vector3.INF

func recursive_create_collision_body(district_child:Node):
	for child in district_child.get_children():
		recursive_create_collision_body(child)
		var meshInstance = child as MeshInstance3D
		if meshInstance: # in case of meshinstance, 
			meshInstance.create_trimesh_collision()
			
			# Get total aabb size of district
			if meshInstance.mesh:
				var aabb:AABB = meshInstance.mesh.get_aabb()
				_district_aa.x = minf(_district_aa.x, aabb.position.x)
				_district_aa.y = minf(_district_aa.y, aabb.position.y)
				_district_aa.z = minf(_district_aa.z, aabb.position.z)
				_district_aa.x = minf(_district_aa.x, aabb.end.x)
				_district_aa.y = minf(_district_aa.y, aabb.end.y)
				_district_aa.z = minf(_district_aa.z, aabb.end.z)
				
				_district_bb.x = maxf(_district_bb.x, aabb.position.x)
				_district_bb.y = maxf(_district_bb.y, aabb.position.y)
				_district_bb.z = maxf(_district_bb.z, aabb.position.z)
				_district_bb.x = maxf(_district_bb.x, aabb.end.x)
				_district_bb.y = maxf(_district_bb.y, aabb.end.y)
				_district_bb.z = maxf(_district_bb.z, aabb.end.z)

# New Viewer functionality
var viewer_offset:Vector2i = Vector2i.ZERO
var viewer_loader:PackedScene = preload("res://modules/viewer/Viewer.tscn")

func create_new_viewer():
	var viewer:Viewer = viewer_loader.instantiate()
	viewer.position = get_window().position + viewer_offset
	viewer_offset += Vector2i(64, 36)
	if viewer_offset.x > 640:
		viewer_offset = Vector2.ZERO
	add_child(viewer)
