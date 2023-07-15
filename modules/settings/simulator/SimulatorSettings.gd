# SingleTone Node SimulatorSettings
extends Node

func reset():
	for vehicle in get_children():
		remove_child(vehicle)
		vehicle.free()

func check_vehicle_exist_and_notify(string:String)->bool:
	if find_vehicle(string):
		Notification.notify("Vehicle "+string+" already exist!", Notification.NOTICE_TYPE.ALERT)
		return true
	return false

func find_vehicle(string:String)->Vehicle:
	return find_child(string, false, false)

func add_vehicle(vehicle:Vehicle):
	if not find_vehicle(vehicle.name):
		add_child(vehicle)

func remove_vehicle(string:String):
	var vehicle:Vehicle = find_vehicle(string)
	if vehicle:
		remove_child(vehicle)
		vehicle.free()
