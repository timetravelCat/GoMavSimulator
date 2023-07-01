extends Node

var model:Array
var vehicleScene:PackedScene

func _enter_tree():
	# see SimulatorSettings.VehicleType for supported models
	print("Loading vehicle models ...")
	model.append(preload("res://modules/vehicle/model/drone.glb"))
	model.append(preload("res://modules/vehicle/model/rover.glb"))
	model.append(preload("res://modules/vehicle/model/plane.glb"))
	
	print("preload vehicle scene")
	vehicleScene = preload("res://modules/vehicle/Vehicle.tscn")
	

func Create(settings:SimulatorSettings.VehicleSetting) -> Vehicle:
	var vehicle = vehicleScene.instantiate()
	vehicle.Setting = settings
	return vehicle
