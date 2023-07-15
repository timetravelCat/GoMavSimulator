class_name VehicleModel extends Node3D

@export var type:MODEL_TYPE
@export var armed:bool
@export_range(0.0, 10.0, 1.0) var rotating_scale:float
@export var meshes:Array[MeshInstance3D]

enum MODEL_TYPE {MULTICOPTER, ROVER, PLANE}
const MODEL_TYPE_STRING:PackedStringArray = [
	"MultiCopter",
	"Rover",
	"Plane"]

static var model_list:Array = [
	preload("res://modules/vehicle/model/drone.tscn"),
	preload("res://modules/vehicle/model/rover.tscn"),
	preload("res://modules/vehicle/model/plane.tscn")
	]

static func Create(vehicle:Vehicle, model_type:MODEL_TYPE)->VehicleModel:
	var model:VehicleModel = model_list[model_type].instantiate()
	model.name = "model"
	if vehicle.model:
		model.scale = vehicle.model.scale
		vehicle.remove_child(vehicle.model)
		vehicle.model.free()
	vehicle.add_child(model)
	vehicle.model = model
	model._set_enable(vehicle.enable)
	vehicle.modelPublisher.surface = model
	return model

func _set_scale(value:float):
	scale = Vector3(value, value, value)

func _set_enable(enable:bool):
	if enable:
		show()
	else:
		hide()

func _process(delta):
	if not armed:
		return
	
	for mesh in meshes:
		mesh.rotate_y(delta*rotating_scale)
