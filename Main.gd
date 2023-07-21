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
	districtSelector.selected = GeneralSettings.district
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
	# disconnect previously connected signals
	if is_instance_valid(thirdPersonCamera.follow):
		var vehicle_pose = thirdPersonCamera.follow.pose as VehiclePose
		if vehicle_pose.is_connected("armed_updated", _on_armed_updated):
			vehicle_pose.disconnect("armed_updated", _on_armed_updated)
		if vehicle_pose.is_connected("flight_mode_updated", _on_flight_mode_updated):
			vehicle_pose.disconnect("flight_mode_updated", _on_flight_mode_updated)
	
	vehicleSelector.release_focus()
	if index == 0:
		freeFlyCamera.make_current()
		return
				
	var vehicle_name = vehicleSelector.get_item_text(index)
	thirdPersonCamera.follow = SimulatorSettings.find_vehicle(vehicle_name) as Vehicle
	thirdPersonCamera.make_current()
	var vehicle_pose = thirdPersonCamera.follow.pose as VehiclePose
	vehicle_pose.connect("armed_updated", _on_armed_updated)
	vehicle_pose.connect("flight_mode_updated", _on_flight_mode_updated)
	
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

@onready var armed_label:Label = $VehicleStatus/HBoxContainer/Armed
@onready var flight_mode_label:Label = $VehicleStatus/HBoxContainer/FlightMode
func _on_armed_updated(armed):
	if armed:
		armed_label.text = "ARMED"
	else:
		armed_label.text = "DISARMED"
func _on_flight_mode_updated(flight_mode):
	match flight_mode:
		GoMAVSDKServer.FLIGHT_MODE_READY:
			flight_mode_label.text = "READY"
		GoMAVSDKServer.FLIGHT_MODE_TAKEOFF:
			flight_mode_label.text = "TAKEOFF"
		GoMAVSDKServer.FLIGHT_MODE_HOLD:
			flight_mode_label.text = "HOLD"
		GoMAVSDKServer.FLIGHT_MODE_MISSION:
			flight_mode_label.text = "MISSION"
		GoMAVSDKServer.FLIGHT_MODE_RETURNTOLAUNCH:
			flight_mode_label.text = "RETURNTOLAUNCH"
		GoMAVSDKServer.FLIGHT_MODE_LAND:
			flight_mode_label.text = "LAND"
		GoMAVSDKServer.FLIGHT_MODE_OFFBOARD:
			flight_mode_label.text = "OFFBOARD"
		GoMAVSDKServer.FLIGHT_MODE_FOLLOWME:
			flight_mode_label.text = "FOLLOWME"
		GoMAVSDKServer.FLIGHT_MODE_MANUAL:
			flight_mode_label.text = "MANUAL"
		GoMAVSDKServer.FLIGHT_MODE_ALTCTL:
			flight_mode_label.text = "ALTCTL"
		GoMAVSDKServer.FLIGHT_MODE_POSCTL:
			flight_mode_label.text = "POSCTL"
		GoMAVSDKServer.FLIGHT_MODE_ACRO:
			flight_mode_label.text = "ACRO"
		GoMAVSDKServer.FLIGHT_MODE_STABILIZED:
			flight_mode_label.text = "STABILIZED"
		GoMAVSDKServer.FLIGHT_MODE_RATTITUDE:
			flight_mode_label.text = "RATTITUDE"
