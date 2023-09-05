extends Control

# vehicle settings
@export var VehicleType:OptionButton
@export var VehicleName:LineEdit
@export var DomainID:LineEdit
@export var PoseSource:OptionButton
@export var VehicleScale:HSlider
@export var VehicleList:ItemList
@export var VehicleDisable:Button

# vehicle advanced settings
@export var VehiclePopup:MarginContainer
@export var MavlinkPoseSource:OptionButton
@export var MavlinkSysId:LineEdit
@export var Ros2PoseSource:LineEdit
@export var PublishVehiclePose:CheckButton
@export var PublishVehicleMesh:CheckButton
@export var PosePublisherFrameID:LineEdit

# sensor settings
@export var SensorType:OptionButton
@export var SensorName:LineEdit
@export var FrameID:LineEdit
@export var PublishRate:LineEdit
@export var LocationX:LineEdit
@export var LocationY:LineEdit
@export var LocationZ:LineEdit
@export var RotationX:LineEdit
@export var RotationY:LineEdit
@export var RotationZ:LineEdit
@export var SensorList:ItemList
@export var SensorDisable:Button

# sensor advanced settings
@export var SensorPopup:MarginContainer
@export var RGBCompress:CheckButton
@export var CameraWidth:LineEdit
@export var CameraHeight:LineEdit
@export var CameraFov:LineEdit
@export var LidarVerticalFov:LineEdit
@export var LidarWidth:LineEdit
@export var LidarHeight:LineEdit
@export var RangeDistance:LineEdit
@export var PanoramaResolution:LineEdit
@export var PanoramaL:CheckBox
@export var PanoramaF:CheckBox
@export var PanoramaR:CheckBox
@export var PanoramaB:CheckBox
@export var PanoramaU:CheckBox
@export var PanoramaD:CheckBox

# Prepare GUI
func _ready():
	ControlMethods.recursive_release_focus(self)

	VehicleList.clear()
	for vehicle in SimulatorSettings.get_children():
		VehicleList.add_item(vehicle.name)

	VehicleType.clear()
	PoseSource.clear()
	SensorType.clear()
	SensorList.clear()
	for type in VehicleModel.MODEL_TYPE_STRING:
		VehicleType.add_item(type)
	for type in VehiclePose.POSE_TYPE_STRING:
		PoseSource.add_item(type)
	for type in Sensor.SENSOR_TYPE_STRING:
		SensorType.add_item(type)
	
	VehicleName.clear()
	DomainID.clear()
	VehicleScale.value = VehicleScale.max_value / 10.0 
	VehicleDisable.text = "DISABLE"
	
	# Veihcle advanced setting
	VehiclePopup.hide()
	MavlinkSysId.clear()
	Ros2PoseSource.clear()
	PosePublisherFrameID.clear()
	
	SensorName.clear()
	FrameID.text = "/map"
	PublishRate.clear()
	LocationX.text = "0.0"
	LocationY.text = "0.0"
	LocationZ.text = "0.0"
	RotationX.text = "0.0"
	RotationY.text = "0.0"
	RotationZ.text = "0.0"
	SensorList.clear()
	SensorDisable.text = "DISABLE"
	
	# Sensor advanced setting
	SensorPopup.hide()
	RGBCompress.disabled = true
	CameraWidth.clear()
	CameraHeight.clear()
	CameraFov.clear()
	LidarVerticalFov.clear()
	LidarWidth.clear()
	LidarHeight.clear()
	RangeDistance.clear()
	PanoramaResolution.clear()

func reset_to_default():
	SimulatorSettings.reset()
	_ready()

# =========== Vehicle ========== #
func get_selected_vehicle()->Vehicle:
	if not ControlMethods.check_anything_selected_and_notify(VehicleList, " Select Any Vehicle "):
		return null
	return SimulatorSettings.find_vehicle(ControlMethods.get_selected_item_text(VehicleList))

func get_selected_vehicle_silent()->Vehicle:
	if VehicleList.is_anything_selected():
		return SimulatorSettings.find_vehicle(ControlMethods.get_selected_item_text(VehicleList))
	else:
		return null

func _on_vehicle_add_pressed():
	if not ControlMethods.check_valid_string_and_notify(VehicleName, " Vehicle Name Empty! "):
		return 
	if not ControlMethods.check_valid_int_and_notify(DomainID, " Domain ID invalid! "):
		return 
	if SimulatorSettings.check_vehicle_exist_and_notify(VehicleName.text):
		return
	
	var vehicle = Vehicle.Create(VehicleName.text) as Vehicle
	SimulatorSettings.add_vehicle(vehicle)
	vehicle.model_type = VehicleType.selected as VehicleModel.MODEL_TYPE
	vehicle.pose_type = PoseSource.selected as VehiclePose.POSE_TYPE
	vehicle.domain_id = DomainID.text.to_int()
	set_vehicle_scale_from_slider(vehicle)
	# TODO handle advanecd settings?
	var vehicle_item = VehicleList.add_item(vehicle.name)
	VehicleList.select(vehicle_item)
	VehicleList.item_selected.emit(vehicle_item)

func _on_vehicle_list_item_selected(index):
	var vehicle = SimulatorSettings.find_vehicle(VehicleList.get_item_text(index)) as Vehicle
	VehicleName.text = vehicle.name
	VehicleType.select(vehicle.model_type)
	DomainID.text = str(vehicle.domain_id)	
	PoseSource.selected = vehicle.pose_type
	set_slider_value_from_vehicle(vehicle)
	VehicleDisable.text = "DISABLE" if vehicle.enable else "ENABLE"
	MavlinkPoseSource.selected = vehicle.odometry_source
	MavlinkSysId.text = str(vehicle.sys_id)
	Ros2PoseSource.text = vehicle.pose_name
	PosePublisherFrameID.text = vehicle.pose_frame_id
	PublishVehiclePose.set_pressed_no_signal(vehicle.enable_pose_publish)
	PublishVehicleMesh.set_pressed_no_signal(vehicle.enable_model_publish)
	
	SensorList.clear()
	for sensor in vehicle.get_sensors():
		SensorList.add_item(sensor.name)

	MavlinkPoseSourceContainer.hide()
	MavlinkSystemIDCotainer.hide()
	Ros2PoseSourceContainer.hide()
	match vehicle.pose_type:
		VehiclePose.POSE_TYPE.MAVLINK:
			MavlinkPoseSourceContainer.show()
			MavlinkSystemIDCotainer.show()
		VehiclePose.POSE_TYPE.ROS2:
			Ros2PoseSourceContainer.show()
		VehiclePose.POSE_TYPE.USER:
			pass

func _on_vehicle_delete_pressed():
	if not ControlMethods.check_anything_selected_and_notify(VehicleList, "Select Any Vehicle"):
		return
	SimulatorSettings.remove_vehicle(get_selected_vehicle().name)
	VehicleList.remove_item(VehicleList.get_selected_items()[0])

func _on_vehicle_disable_pressed():
	if not ControlMethods.check_anything_selected_and_notify(VehicleList, "Select Any Vehicle"):
		return
	
	var item = VehicleList.get_selected_items()[0]
	var vehicle:Vehicle = get_selected_vehicle()
	vehicle.enable = !vehicle.enable
	if vehicle.enable:
		VehicleList.set_item_custom_fg_color(item, Color(1.0, 1.0, 1.0, 1.0))
		VehicleDisable.text = "DISABLE"
	else:
		VehicleList.set_item_custom_fg_color(item, Color(1.0, 1.0, 1.0, 0.2))	
		VehicleDisable.text = "ENABLE"	

func _on_vehicle_type_item_selected(index):
	var vehicle = get_selected_vehicle_silent() as Vehicle
	if vehicle:
		vehicle.model_type = index as VehicleModel.MODEL_TYPE

func _on_vehicle_name_text_submitted(new_text:String):
	var vehicle = get_selected_vehicle_silent() as Vehicle
	if vehicle and ControlMethods.check_valid_string_and_notify(VehicleName, "Vehicle Name Unvalid"):
		if SimulatorSettings.find_vehicle(new_text):
			Notification.notify("Same Vehicle Name Exists", Notification.NOTICE_TYPE.ALERT)
		else:
			vehicle.name = new_text
			VehicleList.set_item_text(VehicleList.get_selected_items()[0], vehicle.name)		

func _on_domain_id_text_submitted(new_text:String):
	var vehicle = get_selected_vehicle_silent() as Vehicle
	if vehicle and ControlMethods.check_valid_int_and_notify(DomainID, "Domain ID Invalid"):
		vehicle.domain_id = new_text.to_int()

func _on_pose_source_item_selected(index):
	var vehicle = get_selected_vehicle_silent() as Vehicle
	if vehicle:
		vehicle.pose_type = index as VehiclePose.POSE_TYPE
		VehicleList.item_selected.emit(VehicleList.get_selected_items()[0])
		
@warning_ignore("unused_parameter")
func _on_vehicle_scale_value_changed(value):
	var vehicle = get_selected_vehicle_silent() as Vehicle
	if vehicle:
		set_vehicle_scale_from_slider(vehicle)

# ========== Vehicle Advanced =========== #
@export var MavlinkPoseSourceContainer:HBoxContainer
@export var MavlinkSystemIDCotainer:HBoxContainer
@export var Ros2PoseSourceContainer:HBoxContainer

func _on_vehicle_advanced_config_pressed():
	if not ControlMethods.check_anything_selected_and_notify(VehicleList, " Select Any Vehicle "):
		return
	VehiclePopup.show()

func _on_vehicle_setup_close_pressed():
	VehiclePopup.hide()

func _on_mavlink_pose_source_item_selected(index):
	var vehicle = get_selected_vehicle_silent() as Vehicle
	vehicle.odometry_source = index

func _on_sysid_text_submitted(new_text:String):
	var vehicle = get_selected_vehicle_silent() as Vehicle
	if not ControlMethods.check_valid_int_and_notify(MavlinkSysId, " Mavlink System ID invalid "):
		return
	vehicle.sys_id = new_text.to_int()

func _on_topic_text_submitted(new_text):
	var vehicle = get_selected_vehicle_silent() as Vehicle
	if not ControlMethods.check_valid_string_and_notify(Ros2PoseSource, " Ros2 Topic Name is Invalid "):
		return 	
	vehicle.pose_name = new_text

func _on_publish_vehicle_pose_toggled(button_pressed):
	print(button_pressed)
	var vehicle = get_selected_vehicle_silent() as Vehicle
	vehicle.enable_pose_publish = button_pressed
	
func _on_publish_vehicle_mesh_toggled(button_pressed):
	var vehicle = get_selected_vehicle_silent() as Vehicle
	vehicle.enable_model_publish = button_pressed

func _on_pose_frame_id_text_submitted(new_text):
	var vehicle = get_selected_vehicle_silent() as Vehicle
	if not ControlMethods.check_valid_string_and_notify(PosePublisherFrameID, " Frame ID is Invalid "):
		return 	
	vehicle.pose_frame_id = new_text

# ========== Sensor ============ #
func get_selected_sensor()->Sensor:
	var vehicle = get_selected_vehicle() as Vehicle
	if not vehicle:
		return null
	if not ControlMethods.check_anything_selected_and_notify(SensorList, " Select Any Sensor "):
		return null
	return vehicle.get_sensor(ControlMethods.get_selected_item_text(SensorList))

func get_selected_sensor_silent()->Sensor:
	if SensorList.is_anything_selected():
		var vehicle = get_selected_vehicle_silent() as Vehicle
		return vehicle.get_sensor(ControlMethods.get_selected_item_text(SensorList))
	else:
		return null

func _on_sensor_add_pressed():
	if not ControlMethods.check_anything_selected_and_notify(VehicleList, " Select Any Vehicle "):
		return 
	if not ControlMethods.check_valid_string_and_notify(SensorName, " Sensor Name is Empty "):
		return
	if not ControlMethods.check_valid_string_and_notify(FrameID, " FrameID is Empty "):
		return
	if not ControlMethods.check_valid_float_and_notify(PublishRate, " Publish Rate is Invalid "):
		return
	if not ControlMethods.check_valid_float_and_notify(LocationX, " Sensor Location is Invalid "):
		return
	if not ControlMethods.check_valid_float_and_notify(LocationY, " Sensor Location is Invalid "):
		return
	if not ControlMethods.check_valid_float_and_notify(LocationZ, " Sensor Location is Invalid "):
		return
	if not ControlMethods.check_valid_float_and_notify(RotationX, " Sensor Rotation is Invalid "):
		return
	if not ControlMethods.check_valid_float_and_notify(RotationY, " Sensor Rotation is Invalid "):
		return
	if not ControlMethods.check_valid_float_and_notify(RotationZ, " Sensor Rotation is Invalid "):
		return

	var vehicle = SimulatorSettings.find_vehicle(ControlMethods.get_selected_item_text(VehicleList)) as Vehicle
	if vehicle.get_sensor(SensorName.text):
		Notification.notify(" Sensor Name Exists ", Notification.NOTICE_TYPE.ALERT)
		return
		
	var sensor = vehicle.add_sensor(SensorType.selected, SensorName.text) as Sensor
	sensor.hz = PublishRate.text.to_float()
	sensor.position = ENU2EUS.enu_to_eus_v(Vector3(LocationX.text.to_float(), LocationY.text.to_float(), LocationZ.text.to_float()))
	sensor.basis = ENU2EUS.enu_to_eus_b(Basis.from_euler(Vector3(deg_to_rad(RotationX.text.to_float()), deg_to_rad(RotationY.text.to_float()), deg_to_rad(RotationZ.text.to_float())), EULER_ORDER_ZYX))
	sensor.publisher.frame_id = FrameID.text
	sensor.publisher.domain_id = vehicle.domain_id
	SensorList.add_item(sensor.name)

func _on_sensor_delete_pressed():
	var sensor = get_selected_sensor()
	if not sensor:
		return 
	var vehicle = get_selected_vehicle()
	vehicle.remove_sensor(sensor.name)
	SensorList.remove_item(SensorList.get_selected_items()[0])

func _on_sensor_disable_pressed():
	var sensor = get_selected_sensor() as Sensor
	if not sensor:
		return
	
	var item = SensorList.get_selected_items()[0]
	sensor.enable = !sensor.enable
	if sensor.enable:
		SensorList.set_item_custom_fg_color(item, Color(1.0, 1.0, 1.0, 1.0))
		SensorDisable.text = "DISABLE"		
	else:
		SensorList.set_item_custom_fg_color(item, Color(1.0, 1.0, 1.0, 0.2))
		SensorDisable.text = "ENABLE"			

@warning_ignore("unused_parameter")
func _on_sensor_list_item_selected(index):
	var sensor = get_selected_sensor() as Sensor
	SensorType.selected = sensor.type
	SensorName.text = sensor.name
	FrameID.text = sensor.publisher.frame_id
	PublishRate.text = str(sensor.hz)
	var sensor_position = ENU2EUS.eus_to_enu_v(sensor.position) as Vector3
	var sensor_rotation = ENU2EUS.eus_to_enu_b(sensor.basis) as Basis
	LocationX.text = str(sensor_position.x)
	LocationY.text = str(sensor_position.y)
	LocationZ.text = str(sensor_position.z)
	var euler = sensor_rotation.get_euler(EULER_ORDER_ZYX) as Vector3
	RotationX.text = str(rad_to_deg(euler.x))
	RotationY.text = str(rad_to_deg(euler.y))
	RotationZ.text = str(rad_to_deg(euler.z))
	SensorDisable.text = "DISABLE" if sensor.enable else "ENABLE"
	
	compress_container.hide()
	camera_resolution_container.hide()
	camera_fov_container.hide()
	lidar_vertical_fov_container.hide()
	lidar_resolution_contanier.hide()
	lidar_range_distance_container.hide()
	panorama_container.hide()
	match sensor.type:
		Sensor.SENSOR_TYPE.RANGE:
			RangeDistance.text = str(sensor.distance)
			lidar_range_distance_container.show()

		Sensor.SENSOR_TYPE.LIDAR:
			RangeDistance.text = str(sensor.distance)
			LidarWidth.text = str(sensor.resolution.x)
			LidarHeight.text = str(sensor.resolution.y)
			LidarVerticalFov.text = str(sensor.vertical_fov)
			lidar_range_distance_container.show()
			lidar_resolution_contanier.show()
			lidar_vertical_fov_container.show()

		Sensor.SENSOR_TYPE.RGB_CAMERA:
			CameraWidth.text = str(sensor.resolution.x)
			CameraHeight.text = str(sensor.resolution.y)
			CameraFov.text = str(sensor.fov)
			RGBCompress.set_pressed_no_signal(sensor.compressed)
			compress_container.show()
			camera_resolution_container.show()
			camera_fov_container.show()

		Sensor.SENSOR_TYPE.DEPTH_CAMERA:
			CameraWidth.text = str(sensor.resolution.x)
			CameraHeight.text = str(sensor.resolution.y)
			CameraFov.text = str(sensor.fov)
			camera_resolution_container.show()
			camera_fov_container.show()
		
		Sensor.SENSOR_TYPE.RGB_PANORAMA:
			panorama_container.show()
			PanoramaResolution.text = str(sensor.resolution)
			PanoramaL.button_pressed = sensor.left
			PanoramaF.button_pressed = sensor.front
			PanoramaR.button_pressed = sensor.right
			PanoramaB.button_pressed = sensor.back
			PanoramaU.button_pressed = sensor.top
			PanoramaD.button_pressed = sensor.bottom
			
		Sensor.SENSOR_TYPE.DEPTH_PANORAMA:
			panorama_container.show()
			PanoramaResolution.text = str(sensor.resolution)
			PanoramaL.button_pressed = sensor.left
			PanoramaF.button_pressed = sensor.front
			PanoramaR.button_pressed = sensor.right
			PanoramaB.button_pressed = sensor.back
			PanoramaU.button_pressed = sensor.top
			PanoramaD.button_pressed = sensor.bottom
			
@warning_ignore("unused_parameter")
func _on_sensor_type_item_selected(index):
	if SensorList.is_anything_selected():
		SensorList.deselect_all()
		Notification.notify("Changing exist sensor type is not supported. Delete and add new sensor.", Notification.NOTICE_TYPE.WARNING)
	
func _on_sensor_name_text_submitted(new_text:String):
	var sensor:Sensor = get_selected_sensor_silent()
	if sensor and ControlMethods.check_valid_string_and_notify(SensorName, "Sensor Name Invalid"):
		sensor.name = new_text
		SensorList.set_item_text(SensorList.get_selected_items()[0], sensor.name)

func _on_frame_id_text_submitted(new_text):
	var sensor:Sensor = get_selected_sensor_silent()
	if sensor and ControlMethods.check_valid_string_and_notify(FrameID, "Frame ID Invalid"):
		sensor.publisher.frame_id = new_text

func _on_publish_rate_text_submitted(new_text:String):
	var sensor:Sensor = get_selected_sensor_silent()
	if sensor and ControlMethods.check_valid_float_and_notify(PublishRate, "Frame ID Invalid"):
		sensor.hz = new_text.to_float()

@warning_ignore("unused_parameter")
func _on_location_text_submitted(new_text:String):
	var sensor:Sensor = get_selected_sensor_silent()
	if sensor and \
		ControlMethods.check_valid_float_and_notify(LocationX, "Sensor Position X Invalid") and \
		ControlMethods.check_valid_float_and_notify(LocationY, "Sensor Position Y Invalid") and \
		ControlMethods.check_valid_float_and_notify(LocationZ, "Sensor Position Z Invalid"):
		sensor.position = ENU2EUS.enu_to_eus_v(Vector3(LocationX.text.to_float(), LocationY.text.to_float(), LocationZ.text.to_float()))

@warning_ignore("unused_parameter")
func _on_rotation_text_submitted(new_text:String):
	var sensor:Sensor = get_selected_sensor_silent()
	if sensor and \
		ControlMethods.check_valid_float_and_notify(RotationX, "Sensor Rotation X Invalid") and \
		ControlMethods.check_valid_float_and_notify(RotationY, "Sensor Rotation Y Invalid") and \
		ControlMethods.check_valid_float_and_notify(RotationZ, "Sensor Rotation Z Invalid"):
		sensor.basis = ENU2EUS.enu_to_eus_b(Basis.from_euler(Vector3(deg_to_rad(RotationX.text.to_float()), deg_to_rad(RotationY.text.to_float()), deg_to_rad(RotationZ.text.to_float())), EULER_ORDER_ZYX))			

# ========== Sensor Advanced =========== #
@export var compress_container:HBoxContainer
@export var camera_resolution_container:HBoxContainer
@export var camera_fov_container:HBoxContainer
@export var lidar_vertical_fov_container:HBoxContainer
@export var lidar_resolution_contanier:HBoxContainer
@export var lidar_range_distance_container:HBoxContainer
@export var panorama_container:HBoxContainer

func _on_sensor_advanced_config_pressed():
	if not ControlMethods.check_anything_selected_and_notify(SensorList, " Select Any Sensor "):
		return
	SensorPopup.show()

func _on_sensor_setup_close_pressed():
	SensorPopup.hide()

func _on_compress_toggled(button_pressed):
	var sensor = get_selected_sensor_silent() as CameraRGB
	if sensor:
		sensor.compressed = button_pressed

func _on_camera_width_text_submitted(new_text:String):
	var sensor = get_selected_sensor_silent() as Sensor
	if sensor and ControlMethods.check_valid_int_and_notify(CameraWidth, "Camera Width Invalid"):
		sensor.resolution.x = new_text.to_int()

func _on_camera_height_text_submitted(new_text:String):
	var sensor = get_selected_sensor_silent() as Sensor
	if sensor and ControlMethods.check_valid_int_and_notify(CameraHeight, "Camera Height Invalid"):
		sensor.resolution.y = new_text.to_int()

func _on_camera_fov_text_submitted(new_text:String):
	var sensor = get_selected_sensor_silent() as Sensor
	if sensor and ControlMethods.check_valid_float_and_notify(CameraFov, "Camera FOV not valid"):
		sensor.fov = new_text.to_float()

func _on_vertical_fov_text_submitted(new_text): ## Not Working?
	var sensor = get_selected_sensor_silent()
	if sensor and ControlMethods.check_valid_float_and_notify(LidarVerticalFov, "Lidar Vertical FOV not valid"):
		sensor.vertical_fov = new_text.to_float()

func _on_lidar_width_text_submitted(new_text):
	var sensor = get_selected_sensor_silent()
	if sensor and ControlMethods.check_valid_int_and_notify(LidarWidth, "Lidar Width not valid"):
		sensor.resolution.x = new_text.to_int()

func _on_lidar_height_text_submitted(new_text): ## Not Working?
	var sensor = get_selected_sensor_silent()
	if sensor and ControlMethods.check_valid_int_and_notify(LidarHeight, "Lidar Height not valid"):
		sensor.resolution.y = new_text.to_int()

func _on_range_distance_text_submitted(new_text:String):
	var sensor = get_selected_sensor_silent()
	if sensor and ControlMethods.check_valid_float_and_notify(RangeDistance, "Lidar Height not valid"):
		sensor.distance = new_text.to_float()

func _on_panorama_resolution_text_submitted(new_text):
	var sensor = get_selected_sensor_silent()
	if sensor and ControlMethods.check_valid_int_and_notify(PanoramaResolution, "Panorama Resolution is not valid"):
		sensor.resolution = new_text.to_int()

func _on_panorama_l_toggled(button_pressed):
	var sensor = get_selected_sensor_silent()
	if sensor:
		sensor.left = button_pressed

func _on_panorama_f_toggled(button_pressed):
	var sensor = get_selected_sensor_silent()
	if sensor:
		sensor.front = button_pressed

func _on_panorama_r_toggled(button_pressed):
	var sensor = get_selected_sensor_silent()
	if sensor:
		sensor.right = button_pressed

func _on_panorama_b_toggled(button_pressed):
	var sensor = get_selected_sensor_silent()
	if sensor:
		sensor.back = button_pressed

func _on_panorama_u_toggled(button_pressed):
	var sensor = get_selected_sensor_silent()
	if sensor:
		sensor.top = button_pressed

func _on_panorama_d_toggled(button_pressed):
	var sensor = get_selected_sensor_silent()
	if sensor:
		sensor.bottom = button_pressed

# =========== input handling ========= #
# release focus if right-mouse clicked
func _on_vehicle_list_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			VehicleList.deselect_all()
			SensorList.clear()

func _on_sensor_list_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			SensorList.deselect_all()

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			ControlMethods.recursive_release_focus(self)
# ========= MISC ========= #
func set_slider_value_from_vehicle(vehicle:Vehicle):
	VehicleScale.value = vehicle.model_scale*VehicleScale.max_value/10.0;
func set_vehicle_scale_from_slider(vehicle:Vehicle):
	vehicle.model_scale = 10.0*VehicleScale.value/VehicleScale.max_value
