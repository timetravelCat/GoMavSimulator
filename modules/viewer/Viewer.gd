class_name Viewer extends GlobalWindow

@onready var freeFlyCamera = $FreeFlyCamera
@onready var thirdPersonCamera = $ThirdPersonCamera
@onready var vehicleSelector:OptionButton = $VehicleSelector

func _on_close_requested():
	call_deferred("queue_free")

# TODO bug on godot : always on top makes other control node weird. (buttons not working)
func _on_always_on_top_toggled(button_pressed):
	always_on_top = button_pressed

func _on_vehicle_selector_pressed():
	vehicleSelector.clear()
	vehicleSelector.add_item("FreeCam")
	# get current vehicle list
	for vehicle in SimulatorSettings.VehicleContainer.get_children():
		vehicleSelector.add_item(vehicle.name)
	vehicleSelector.selected = -1

func _on_vehicle_selector_item_selected(index):
	vehicleSelector.release_focus()
	vehicleSelector.flat = true;
	
	if index == 0:
		vehicleSelector.flat = false;
		freeFlyCamera.make_current()
		title = ""
		return
	
	var key = vehicleSelector.get_item_text(index)
	var vehicle = SimulatorSettings.VehicleContainer.find_child(key, false, false)
	if not vehicle:
		Notification.notify("Vehicle deleted during selection", Notification.NOTICE_TYPE.ALERT) 
		return
	thirdPersonCamera.follow = vehicle
	thirdPersonCamera.make_current()
	title = vehicle.name
		
	
