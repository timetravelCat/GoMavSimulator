extends Node3D

# ====== General Options ======== #
@onready var districtSelector:OptionButton = $Control/MarginContainer/VBoxContainer/DistrictSelector
@onready var vehicleSelector = $Control/MarginContainer/VBoxContainer/VehicleSelector

# ====== Camera Controllers ======= #
@onready var freeFlyCamera:FreeFlyCamera = $FreeFlyCamera
@onready var thirdPersonCamera:ThirdPersonCamera = $ThirdPersonCamera

func _ready():
	get_window().title = "GoMAVSimulator"
	# prepare districtor selector gui 
	districtSelector.clear()
	for district in GeneralSettings.districts_string:
		districtSelector.add_item(district)
	# camera property initialization
	vehicleSelector.add_item("FreeCam")
	vehicleSelector.selected = 0
	
# Handle District Selector
func _on_district_selector_item_selected(index):
	GeneralSettings.district = index
	districtSelector.release_focus()

# Handle Vehicle Selector
func _on_vehicle_selector_pressed():
	vehicleSelector.clear()
	vehicleSelector.add_item("FreeCam")
	
	for vehicle in SimulatorSettings.get_vehicles():
		vehicleSelector.add_item(vehicle.name)
	vehicleSelector.selected = -1
func _on_vehicle_selector_item_selected(index):
	vehicleSelector.release_focus()
	if index == 0:
		freeFlyCamera.make_current()
		return
	
	var vehicle_name = vehicleSelector.get_item_text(index)
	thirdPersonCamera.follow = SimulatorSettings.find_vehicle(vehicle_name) as Vehicle
	thirdPersonCamera.make_current()
func _on_third_person_camera_lost_follow():
	vehicleSelector.selected = 0
	
@onready var settings:Control = $Settings
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			settings.visible = !settings.visible

func _on_settings_visibility_changed():
	freeFlyCamera.control = !settings.visible
	thirdPersonCamera.control = !settings.visible
	# if thirdPersonCamera's vehicle removed, change to freeFlyCamera automatically.
	if not is_instance_valid(thirdPersonCamera.follow):
		thirdPersonCamera.follow = null
		freeFlyCamera.make_current()
	# if setting is visible and thirdPersonCamera's follow target is valid and user-input vehicle, then disable movement.
	if is_instance_valid(thirdPersonCamera.follow):
		var vehicle = thirdPersonCamera.follow as Vehicle
		if vehicle and vehicle.pose_type == VehiclePose.POSE_TYPE.USER:
			if settings.visible:
				vehicle.pose._set_enable(false)
			else:
				vehicle.pose._set_enable(true)



