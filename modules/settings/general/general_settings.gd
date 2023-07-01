extends Node

var selected_world:int = 0
var worlds:Array

func _enter_tree():
	# Register worldEnvironments	
	worlds.append(preload("res://modules/world/environment/Volumetric.tscn"))

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(worlds[selected_world].instantiate())

func get_current_world() -> WorldEnvironment:
	return get_child(0).get_node("WorldEnvironment")
