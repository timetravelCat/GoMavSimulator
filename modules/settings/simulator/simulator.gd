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
@export var CameraWitdh:LineEdit
@export var CameraHeight:LineEdit
@export var CameraFov:LineEdit
@export var LidarVerticalFov:LineEdit
@export var LidarWidth:LineEdit
@export var LidarHeight:LineEdit
@export var RangeDistance:LineEdit

func _ready():
	VehicleType.clear()
	for vehicle_type in Vehicle.MODEL_TYPE_STRING:
		VehicleType.add_item(vehicle_type)
	SensorType.clear()
	for sensor_type in 	Vehicle.SENSOR_TYPE_STRING:
		SensorType.add_item(sensor_type)
	PoseSource.clear()
	for pose_type in Vehicle.POSE_TYPE_STRING:
		PoseSource.add_item(pose_type)
	
func reset_to_default():
	# Set all control node value as default
	VehicleType.select(0)
	VehicleName.clear()
	DomainID.text = str(SimulatorSettings.def_domain_id)
	PoseSource.select(0)
	VehicleScale.value = SimulatorSettings.def_vehicle_scale * (VehicleScale.max_value/SimulatorSettings.def_vehicle_scaler)
	VehicleDisable.text = "DISABLE"
	
	SensorType.select(0)
	SensorName.clear()
	FrameID.text = SimulatorSettings.def_frame_id
	PublishRate.clear()
	LocationX.text = "0.0"
	LocationY.text = "0.0"
	LocationZ.text = "0.0"
	RotationX.text = "0.0"
	RotationY.text = "0.0"
	RotationZ.text = "0.0"
	SensorList.clear()
	SensorDisable.text = "DISABLE"
	
	# Clear VehicleList
	while VehicleList.item_count > 0:
		VehicleList.select(0)
		_on_vehicle_delete_pressed()
	
	if SimulatorSettings.add_vehicle():
			VehicleList.add_item(SimulatorSettings.def_vehicle_name)

func _on_vehicle_add_pressed():
	if VehicleName.text.is_empty():
		Notification.notify(" Empty Veihcle Name ", Notification.NOTICE_TYPE.ALERT)
		return
	
	if !DomainID.text.is_valid_int():
		Notification.notify(" Invalid Domain ID ", Notification.NOTICE_TYPE.ALERT)
		return
	
	var model_type:Vehicle.MODEL_TYPE = VehicleType.selected as Vehicle.MODEL_TYPE
	var pose_type:Vehicle.POSE_TYPE = PoseSource.selected as Vehicle.POSE_TYPE
	if SimulatorSettings.add_vehicle(
		VehicleName.text,
		model_type,
		DomainID.text.to_int(),
		pose_type,
		VehicleScale.value/(VehicleScale.max_value/SimulatorSettings.def_vehicle_scaler),
		GoMAVSDK.OdometrySource.ODOMETRY_GROUND_TRUTH,
		SimulatorSettings.def_sys_id,
		SimulatorSettings.def_ros2_pose_subscriber_topic_name):
			var select_item = VehicleList.add_item(VehicleName.text)
			VehicleList.select(select_item)
			_on_vehicle_list_item_selected(select_item)

func _on_vehicle_delete_pressed():
	if !VehicleList.is_anything_selected():
		Notification.notify(" Select Veihcle ", Notification.NOTICE_TYPE.WARNING)
		return
	
	var item:int = VehicleList.get_selected_items()[0]
	SimulatorSettings.remove_vehicle(VehicleList.get_item_text(item))
	VehicleList.remove_item(item)

func _on_vehicle_disable_pressed():
	if !VehicleList.is_anything_selected():
		Notification.notify(" Select Veihcle ", Notification.NOTICE_TYPE.WARNING)
		return
	
	var item:int = VehicleList.get_selected_items()[0]
	var vehicle = SimulatorSettings.get_vehicle(VehicleList.get_item_text(item)) as Vehicle
	vehicle.enable = !vehicle.enable
	
	if not vehicle.enable:
		VehicleList.set_item_custom_fg_color(item, Color(1.0, 1.0, 1.0, 0.2))	
		VehicleDisable.text = "ENABLE"
	else:
		VehicleList.set_item_custom_fg_color(item, Color(1.0, 1.0, 1.0, 1.0))
		VehicleDisable.text = "DISABLE"
	
func _on_vehicle_list_item_selected(index):
	var vehicle = SimulatorSettings.get_vehicle(VehicleList.get_item_text(index)) as Vehicle
	
	VehicleType.select(vehicle.model_type)
	VehicleName.text = vehicle.name
	DomainID.text = str(vehicle.domain_id)
	PoseSource.selected = vehicle.pose_type
	VehicleScale.set_value_no_signal(vehicle.model.scale.x*VehicleScale.max_value/SimulatorSettings.def_vehicle_scaler)
	VehicleDisable.text = "DISABLE" if vehicle.enable else "ENABLE"
	var pose_mavlink = vehicle.pose as GoMAVSDK
	if pose_mavlink:
		MavlinkPoseSource.selected = pose_mavlink.odometry_source
		MavlinkSysId.text = str(pose_mavlink.sys_id)
		# TODO hide without unrelative options?
		
	var pose_ros2 = vehicle.pose as PoseStampedSubscriber
	if pose_ros2:
		Ros2PoseSource.text = pose_ros2.name
		# TODO hide without unrelative options?
		
	SensorList.clear()
	for sensor in vehicle.sensors:
		SensorList.add_item(sensor.name)

func _on_sensor_add_pressed():
	if SensorName.text.is_empty():
		Notification.notify(" Empty Sensor Name ", Notification.NOTICE_TYPE.ALERT)
		return
	
	if FrameID.text.is_empty():
		Notification.notify(" Empty Frame Name ", Notification.NOTICE_TYPE.ALERT)
		return
	
	if !PublishRate.text.is_valid_float():
		Notification.notify(" Invalid Publish Rate ", Notification.NOTICE_TYPE.ALERT)
		return
	
	if !LocationX.text.is_valid_float() or !LocationY.text.is_valid_float() or !LocationZ.text.is_valid_float():
		Notification.notify(" Invalid Location ", Notification.NOTICE_TYPE.ALERT)
		return
	
	if !RotationX.text.is_valid_float() or !RotationY.text.is_valid_float() or !RotationZ.text.is_valid_float():
		Notification.notify(" Invalid Rotation ", Notification.NOTICE_TYPE.ALERT)
		return
	
	var vehicle:Vehicle = get_selected_vehicle()
	if not vehicle:
		return 
	
	var sensor:Sensor = vehicle.get_sensor(SensorName.text)
	if sensor:
		Notification.notify(" Exists Sensor Name ", Notification.NOTICE_TYPE.ALERT)
		return
	
	var sensor_type:Vehicle.SENSOR_TYPE = SensorType.selected as Vehicle.SENSOR_TYPE
	sensor = vehicle.add_sensor(SensorName.text, sensor_type)
	if not sensor:
		return
	
	sensor.hz = PublishRate.text.to_float()
	sensor.position = ENU2EUS.enu_to_eus_v(Vector3(LocationX.text.to_float(), LocationY.text.to_float(), LocationZ.text.to_float()))
	sensor.basis = ENU2EUS.enu_to_eus_b(Basis.from_euler(Vector3(deg_to_rad(RotationX.text.to_float()), deg_to_rad(RotationY.text.to_float()), deg_to_rad(RotationZ.text.to_float())), EULER_ORDER_ZYX))
	sensor.publisher.frame_id = FrameID.text
	SensorList.add_item(sensor.name)

func _on_sensor_delete_pressed():
	var sensor:Sensor = get_selected_sensor()
	if not sensor:
		return
	
	var vehicle:Vehicle = get_selected_vehicle()
	vehicle.remove_sensor(sensor.name)
	SensorList.remove_item(SensorList.get_selected_items()[0])

func _on_sensor_disable_pressed():
	var sensor:Sensor = get_selected_sensor()
	if not sensor:
		return
		
	var item:int = SensorList.get_selected_items()[0]
	sensor.enable = !sensor.enable
	if !sensor.enable:
		SensorList.set_item_custom_fg_color(item, Color(1.0, 1.0, 1.0, 0.2))
		SensorDisable.text = "ENABLE"
	else:
		SensorList.set_item_custom_fg_color(item, Color(1.0, 1.0, 1.0, 1.0))
		SensorDisable.text = "DISABLE"	

@onready var compress_container = $Margin/SensorPopup/VBoxContainer/HBoxContainer6
@onready var camera_resolution_container = $Margin/SensorPopup/VBoxContainer/HBoxContainer
@onready var camera_fov_container = $Margin/SensorPopup/VBoxContainer/HBoxContainer5
@onready var lidar_vertical_fov_container = $Margin/SensorPopup/VBoxContainer/HBoxContainer2
@onready var lidar_resolution_contanier = $Margin/SensorPopup/VBoxContainer/HBoxContainer3
@onready var lidar_range_distance_container = $Margin/SensorPopup/VBoxContainer/HBoxContainer4

@warning_ignore("unused_parameter")
func _on_sensor_list_item_selected(index):
	var sensor:Sensor = get_selected_sensor()
	var vehicle:Vehicle = get_selected_vehicle()
	if not sensor or not vehicle:
		return
	
	# set common settings
	SensorType.selected = sensor.type #.select(sensor.type)
	SensorName.text = sensor.name
	FrameID.text = sensor.publisher.frame_id
	PublishRate.text = str(sensor.hz)
	var sensor_position:Vector3 = ENU2EUS.eus_to_enu_v(sensor.position)
	var sensor_rotation:Basis = ENU2EUS.eus_to_enu_b(sensor.basis)
	LocationX.text = str(sensor_position.x)
	LocationY.text = str(sensor_position.y)
	LocationZ.text = str(sensor_position.z)
	var euler:Vector3 = sensor_rotation.get_euler(EULER_ORDER_ZYX)
	RotationX.text = str(rad_to_deg(euler.x))
	RotationY.text = str(rad_to_deg(euler.y))
	RotationZ.text = str(rad_to_deg(euler.z))
	SensorDisable.text = "DISABLE" if sensor.enable else "ENABLE"
	
	# Hide 
	compress_container.hide()
	camera_resolution_container.hide()
	camera_fov_container.hide()
	lidar_vertical_fov_container.hide()
	lidar_resolution_contanier.hide()
	lidar_range_distance_container.hide()
	
	match sensor.type:
		Vehicle.SENSOR_TYPE.RANGE:
			RangeDistance.text = str(sensor.distance)
			lidar_range_distance_container.show()
			
		Vehicle.SENSOR_TYPE.LIDAR:
			RangeDistance.text = str(sensor.distance)
			LidarWidth.text = str(sensor.resolution.x)
			LidarHeight.text = str(sensor.resolution.y)
			LidarVerticalFov.text = str(sensor.vertical_fov)
			lidar_range_distance_container.show()
			lidar_resolution_contanier.show()
			lidar_vertical_fov_container.show()
			
		Vehicle.SENSOR_TYPE.RGB_CAMERA:
			CameraWitdh.text = str(sensor.resolution.x)
			CameraHeight.text = str(sensor.resolution.y)
			CameraFov.text = str(sensor.fov)
			RGBCompress.set_pressed_no_signal(sensor.compressed)
			compress_container.show()
			camera_resolution_container.show()
			camera_fov_container.show()
			
		Vehicle.SENSOR_TYPE.DEPTH_CAMERA:
			CameraWitdh.text = str(sensor.resolution.x)
			CameraHeight.text = str(sensor.resolution.y)
			CameraFov.text = str(sensor.fov)
			camera_resolution_container.show()
			camera_fov_container.show()

func get_selected_vehicle(notify:bool = true)->Vehicle:
	if !VehicleList.is_anything_selected():
		if notify:
			Notification.notify(" Select a vehicle ", Notification.NOTICE_TYPE.ALERT)
		return null
	
	return SimulatorSettings.get_vehicle(VehicleList.get_item_text(VehicleList.get_selected_items()[0]))
	
func get_selected_sensor(notify:bool = true)->Sensor:
	var vehicle:Vehicle = get_selected_vehicle()
	if not vehicle:
		return null
	
	if not SensorList.is_anything_selected():
		if notify:
			Notification.notify(" Select a sensor ", Notification.NOTICE_TYPE.ALERT)
		return null
	
	return vehicle.get_sensor(SensorList.get_item_text(SensorList.get_selected_items()[0]))
func _on_vehicle_advanced_config_pressed():
	if !VehicleList.is_anything_selected():
		Notification.notify(" Select Veihcle ", Notification.NOTICE_TYPE.ALERT)
		return
	VehiclePopup.show()
func _on_sensor_advanced_config_pressed():
	if !SensorList.is_anything_selected():
		Notification.notify(" Select Sensor ", Notification.NOTICE_TYPE.ALERT)
		return
	SensorPopup.show()
func _on_vehicle_setup_close_pressed():
	VehiclePopup.hide()
func _on_sensor_setup_close_pressed():
	SensorPopup.hide()
# diselect if right-mouse clicked
func _on_vehicle_list_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			SensorList.deselect_all()
			VehicleList.deselect_all()
func _on_sensor_list_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			SensorList.deselect_all()

func _on_vehicle_type_item_selected(index):
	var vehicle = get_selected_vehicle(false)
	var model_type:Vehicle.MODEL_TYPE = index as Vehicle.MODEL_TYPE
	if vehicle:
		vehicle.model_type = model_type

func _on_vehicle_name_text_submitted(new_text:String):
	var vehicle = get_selected_vehicle(false)
	if vehicle and not new_text.is_empty():
		vehicle.name = new_text
		VehicleList.set_item_text(VehicleList.get_selected_items()[0], vehicle.name)
		
func _on_domain_id_text_submitted(new_text:String):
	var vehicle = get_selected_vehicle(false)
	if vehicle and not new_text.is_empty() and new_text.is_valid_int():
		vehicle.domain_id = new_text.to_int()

func _on_pose_source_item_selected(index):
	var vehicle = get_selected_vehicle(false)
	var pose_type:Vehicle.POSE_TYPE = index as Vehicle.POSE_TYPE
	if vehicle:
		vehicle.pose_type = pose_type
		
func _on_vehicle_scale_value_changed(value):
	var vehicle = get_selected_vehicle(false)
	if vehicle:
		var model_scale:float = value * SimulatorSettings.def_vehicle_scaler / VehicleScale.max_value
		vehicle.model.scale = Vector3(model_scale, model_scale, model_scale)

# vehicle advanced config
func _on_mavlink_pose_source_item_selected(index):
	var vehicle = get_selected_vehicle(false)
	var mavlink_pose_type:GoMAVSDK.OdometrySource = index as GoMAVSDK.OdometrySource
	if vehicle and vehicle.pose_type == Vehicle.POSE_TYPE.MAVLINK:
		var pose_mavlink:GoMAVSDK = vehicle.pose
		pose_mavlink.odometry_source = mavlink_pose_type

func _on_sysid_text_submitted(new_text:String):
	var vehicle = get_selected_vehicle(false)
	if vehicle and vehicle.pose_type == Vehicle.POSE_TYPE.MAVLINK and new_text.is_valid_int():
		var pose_mavlink:GoMAVSDK = vehicle.pose
		pose_mavlink.sys_id = new_text.to_int()

func _on_topic_text_submitted(new_text):
	var vehicle = get_selected_vehicle(false)
	if vehicle and vehicle.pose_type == Vehicle.POSE_TYPE.ROS2 and !vehicle.find_child(new_text, false, false):
		var pose_ros2:PoseStampedSubscriber = vehicle.pose
		pose_ros2.name = new_text

@warning_ignore("unused_parameter")
func _on_sensor_type_item_selected(index):
	if SensorList.is_anything_selected():
		Notification.notify("Changing exist sensor is not supported. Delete and add new sensor.", Notification.NOTICE_TYPE.WARNING)

func _on_sensor_name_text_submitted(new_text:String):
	var sensor:Sensor = get_selected_sensor(false)
	if sensor and !new_text.is_empty():
		sensor.name = new_text
		SensorList.set_item_text(SensorList.get_selected_items()[0], sensor.name)

func _on_frame_id_text_submitted(new_text):
	var sensor:Sensor = get_selected_sensor(false)
	if sensor and !new_text.is_empty():
		sensor.publisher.frame_id = new_text

func _on_publish_rate_text_submitted(new_text:String):
	var sensor:Sensor = get_selected_sensor(false)
	if sensor and !new_text.is_empty() and new_text.is_valid_float():
		sensor.hz = new_text.to_float()

func _on_location_text_submitted(new_text:String):
	var sensor:Sensor = get_selected_sensor(false)
	if sensor and !new_text.is_empty() and new_text.is_valid_float():
		sensor.position = ENU2EUS.enu_to_eus_v(Vector3(LocationX.text.to_float(), LocationY.text.to_float(), LocationZ.text.to_float()))

func _on_rotation_text_submitted(new_text:String):
	var sensor:Sensor = get_selected_sensor(false)
	if sensor and !new_text.is_empty() and new_text.is_valid_float():
		sensor.basis = ENU2EUS.enu_to_eus_b(Basis.from_euler(Vector3(deg_to_rad(RotationX.text.to_float()), deg_to_rad(RotationY.text.to_float()), deg_to_rad(RotationZ.text.to_float())), EULER_ORDER_ZYX))

#func _check_valid_float(lineEdit:LineEdit)->bool:
#	if lineEdit.text.is_empty() or not lineEdit.text.is_valid_float():
#		Notification.notify("Unvalid input")
#		lineEdit.text = ""
#		return false
#	return true
#
#func _check_valid_int(lineEdit:LineEdit)->bool:
#	if lineEdit.text.is_empty() or not lineEdit.text.is_valid_int():
#		Notification.notify("Unvalid input")
#		lineEdit.text = ""
#		return false
#	return true

# sensor advanced config
func _on_compress_toggled(button_pressed):
	var sensor = get_selected_sensor(false)
	if sensor:
		get_selected_sensor(false).compressed = button_pressed

func _on_camera_width_text_submitted(new_text:String):
	var sensor = get_selected_sensor(false)
	if sensor and !new_text.is_empty() and new_text.is_valid_int():
		sensor.resolution.x = new_text.to_int()

func _on_camera_height_text_submitted(new_text:String):
	var sensor = get_selected_sensor(false)
	if sensor and !new_text.is_empty() and new_text.is_valid_int():
		sensor.resolution.y = new_text.to_int()

func _on_camera_fov_text_submitted(new_text:String):
	var sensor = get_selected_sensor(false)
	if sensor and !new_text.is_empty() and new_text.is_valid_float():
		sensor.fov = new_text.to_float()

func _on_vertical_fov_text_submitted(new_text): ## Not Working?
	var sensor = get_selected_sensor(false)
	if sensor and !new_text.is_empty() and new_text.is_valid_float():
		sensor.vertical_fov = new_text.to_float()

func _on_lidar_width_text_submitted(new_text):
	var sensor = get_selected_sensor(false)
	if sensor and !new_text.is_empty() and new_text.is_valid_int():
		sensor.resolution.x = new_text.to_int()

func _on_lidar_height_text_submitted(new_text): ## Not Working?
	var sensor = get_selected_sensor(false)
	if sensor and !new_text.is_empty() and new_text.is_valid_int():
		sensor.resolution.y = new_text.to_int()

func _on_range_distance_text_submitted(new_text:String):
	var sensor = get_selected_sensor(false)
	if sensor and !new_text.is_empty() and new_text.is_valid_float():
		sensor.distance = new_text.to_float()
