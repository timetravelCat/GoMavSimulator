# SingleTone Node SimulatorSettings
extends Node

@export var save_path:String

func _ready():
	if save_path.is_empty():
		return
	
	if not FileAccess.file_exists(save_path):
		return
		
	var file_access := FileAccess.open(save_path, FileAccess.READ)
	while file_access.get_position() < file_access.get_length():
		var json_string = file_access.get_line()
		var json:JSON = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			continue
		var vehicles = json.get_data()
		for vehicle in vehicles:
			add_vehicle(Vehicle.Create("", vehicles[vehicle]))
	
func _exit_tree():
	if save_path.is_empty():
		return
	# Save Vehicle data in Dictionary of { ID(integer), Dictionary of {property_name, value} }
	@warning_ignore("unassigned_variable")
	var data:Dictionary
	var file_access = FileAccess.open(save_path, FileAccess.WRITE)
	var index:int = 0
	for vehicle in get_children():
		var vehicle_data:Dictionary = DefaultSettingMethods.get_property_data(vehicle, vehicle.property_saved_list) 
		@warning_ignore("unassigned_variable")
		var sensor_data:Dictionary
		for sensor in vehicle.get_sensors():
			var sensor_dictionary:Dictionary = DefaultSettingMethods.get_property_data(sensor, sensor.property_saved_list) 
			sensor_dictionary.merge({"type":sensor.type}) # types must be stored.
			sensor_data.merge({sensor.name:sensor_dictionary})
		vehicle_data.merge({"sensors":sensor_data})
		data.merge({index:vehicle_data})
		index += 1
	file_access.store_line(JSON.stringify(data))
	file_access.close()

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
