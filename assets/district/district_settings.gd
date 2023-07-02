extends Node

# cartoon district
var district_mumbai:PackedScene = preload("res://assets/district/cartoon/mumbai.tscn")
var district_mini:PackedScene = preload("res://assets/district/cartoon/mini.tscn")
var collisionDistrict:StaticBody3D

func _ready():
	# TODO implement save-load
	# TODO select by start settings
	var district:Node3D = district_mumbai.instantiate()
	district.name = "district"
	# recursive call for all meshes in create_trimesh_collision
	print("Create static body of district")
	recursive_create_collision_body(district)
	add_child(district)

func recursive_create_collision_body(district_child:Node):
	for child in district_child.get_children():
		recursive_create_collision_body(child)
		var meshInstance = child as MeshInstance3D
		if meshInstance: # in case of meshinstance, 
			meshInstance.create_trimesh_collision()
