extends Node

var selected_world:int = 0
var world_volumetric = preload("res://modules/world/environment/Volumetric.tscn")

var district_mumbai:PackedScene = preload("res://assets/district/cartoon/mumbai.tscn")
var district_mini:PackedScene = preload("res://assets/district/cartoon/mini.tscn")

func _enter_tree():
	# TODO implement save-load
	# TODO select by start settings
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	# Regieter world
	var world:Node3D = world_volumetric.instantiate()
	world.name = "world"
	add_child(world)
	
	# Register district
	var district:Node3D = district_mumbai.instantiate()
	district.name = "district"
	recursive_create_collision_body(district)
	add_child(district)

func get_current_world() -> WorldEnvironment:
	return find_child("world").get_node("WorldEnvironment")

func recursive_create_collision_body(district_child:Node):
	for child in district_child.get_children():
		recursive_create_collision_body(child)
		var meshInstance = child as MeshInstance3D
		if meshInstance: # in case of meshinstance, 
			meshInstance.create_trimesh_collision()
