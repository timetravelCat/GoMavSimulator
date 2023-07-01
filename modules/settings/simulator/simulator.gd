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
@export var CameraWitdh:LineEdit
@export var CameraHeight:LineEdit
@export var LidarVerticalFov:LineEdit
@export var LidarWidth:LineEdit
@export var LidarHeigth:LineEdit

func reset_to_default():
	# Set all control node value as default
	VehicleType.select(0)
	VehicleName.clear()
	DomainID.text = "0"
	PoseSource.select(0)
	VehicleScale.value = SimulatorSettings.VEHICLE_DEFAULT_SCALE
	VehicleDisable.text = "DISABLE"
	
	SensorType.select(0)
	SensorName.clear()
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
	
	# Load Default Vehicle 
	var NewVehicle = SimulatorSettings.Vehicle.new()
	NewVehicle.item_id = VehicleList.add_item(NewVehicle.name)
	# (TODO add default sensor)
	SimulatorSettings.VehicleList.merge({NewVehicle.name: NewVehicle})
	

func _on_vehicle_add_pressed():
	if VehicleName.text.is_empty():
		Notification.notify(" Empty Veihcle Name ", Notification.NOTICE_TYPE.ALERT)
		return
	
	if !DomainID.text.is_valid_int():
		Notification.notify(" Invalid Domain ID ", Notification.NOTICE_TYPE.ALERT)
		return
	
	if SimulatorSettings.VehicleList.has(VehicleName.text):
		Notification.notify(" Exist Veihcle Name ", Notification.NOTICE_TYPE.ALERT)
		return
	
	var NewVehicle = SimulatorSettings.VehicleSetting.new()
	NewVehicle.enable = true
	NewVehicle.name = VehicleName.text
	NewVehicle.type = VehicleType.selected
	NewVehicle.scale = VehicleScale.value / SimulatorSettings.VEHICLE_DEFAULT_SCALE
	NewVehicle.pose_source = PoseSource.selected
	NewVehicle.domain_id = DomainID.text.to_int()
#	# advanced setting
	NewVehicle.mavlink_pose_source = SimulatorSettings.MAVLINK_POSE_SOURCE_DEFAULT
	NewVehicle.sys_id = SimulatorSettings.VEHILE_SYSID_DEFAULT
	NewVehicle.ros2_pose_source = SimulatorSettings.ROS2_POSE_TOPIC_DEFAULT
	
	# Register VehicleList
	NewVehicle.item_id = VehicleList.add_item(NewVehicle.name)
	SimulatorSettings.VehicleList.merge({NewVehicle.name: NewVehicle})

func _on_vehicle_delete_pressed():
	if !VehicleList.is_anything_selected():
		Notification.notify(" Select Veihcle ", Notification.NOTICE_TYPE.WARNING)
		return
	
	var item:int = VehicleList.get_selected_items()[0]
	var key:String = VehicleList.get_item_text(item)
	SimulatorSettings.VehicleList.erase(key)
	VehicleList.remove_item(item)

func _on_vehicle_disable_pressed():
	if !VehicleList.is_anything_selected():
		Notification.notify(" Select Veihcle ", Notification.NOTICE_TYPE.WARNING)
		return
	
	var item:int = VehicleList.get_selected_items()[0]
	var key:String = VehicleList.get_item_text(item)
	if SimulatorSettings.VehicleList.has(key):
		var vehicle := SimulatorSettings.VehicleList[key] as SimulatorSettings.VehicleSetting
		vehicle.enable = !vehicle.enable
		
		# set color
		if !vehicle.enable:
			VehicleList.set_item_custom_fg_color(item, Color(1.0, 1.0, 1.0, 0.2))	
			VehicleDisable.text = "ENABLE"
		else :
			VehicleList.set_item_custom_fg_color(item, Color(1.0, 1.0, 1.0, 1.0)) # Enabled color
			VehicleDisable.text = "DISABLE"
	
func _on_vehicle_list_item_selected(index):
	var key:String = VehicleList.get_item_text(index)
	if SimulatorSettings.VehicleList.has(key):
		var vehicle := SimulatorSettings.VehicleList[key] as SimulatorSettings.VehicleSetting
		
		VehicleType.select(vehicle.type)
		VehicleName.text = vehicle.name
		DomainID.text = str(vehicle.domain_id)
		PoseSource.select(vehicle.pose_source)
		VehicleScale.set_value_no_signal(vehicle.scale * SimulatorSettings.VEHICLE_DEFAULT_SCALE)
		VehicleDisable.text = "DISABLE" if vehicle.enable else "ENABLE"
		MavlinkPoseSource.select(vehicle.mavlink_pose_source)
		MavlinkSysId.text = str(vehicle.sys_id)
		Ros2PoseSource.text = vehicle.ros2_pose_source
		
		# Set sensor item list
		SensorList.clear()
		for sensor_name in vehicle.sensors.keys():
			SensorList.add_item(sensor_name)

func _on_sensor_add_pressed():
	if SensorName.text.is_empty():
		Notification.notify(" Empty Sensor Name ", Notification.NOTICE_TYPE.ALERT)
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
	
	var vehicle:SimulatorSettings.VehicleSetting = get_selected_vehicle()
	if vehicle == null:
		return
		
	if vehicle.sensors.has(SensorName.text):
		Notification.notify(" Exist Sensor Name ", Notification.NOTICE_TYPE.ALERT)
		return
	
	var NewSensor = SimulatorSettings.Sensor.new()
	NewSensor.enable = true
	NewSensor.type = SensorType.selected
	NewSensor.name = SensorName.text
	NewSensor.hz = PublishRate.text.to_float()
	# Stored as EUS frame
	NewSensor.location = ENU2EUS.enu_to_eus_v(Vector3(LocationX.text.to_float(), LocationY.text.to_float(), LocationZ.text.to_float())) 
	NewSensor.rotation = ENU2EUS.enu_to_eus_b(Basis.from_euler(Vector3(deg_to_rad(RotationX.text.to_float()), deg_to_rad(RotationY.text.to_float()), deg_to_rad(RotationZ.text.to_float())), EULER_ORDER_ZYX))
	
	# Advanced configuration
	match NewSensor.type: 	# NewSensor.resoultion =  Vector2i(CameraWitdh.text.to_int(), CameraHeight.text.to_int())
		SimulatorSettings.SENSOR_TYPE.RGB_CAMERA:
			NewSensor.resoultion = SimulatorSettings.RGB_CAMERA_DEFAULT_RESOLUTION
		SimulatorSettings.SENSOR_TYPE.DEPTH_CAMERA:
			NewSensor.resoultion = SimulatorSettings.DEPTH_CAMERA_DEFUALT_RESOLUTION
			
	NewSensor.vertical_fov = SimulatorSettings.LIDAR_DEFAULT_VERTICAL_FOV # deg_to_rad(LidarVerticalFov.text.to_float())
	NewSensor.vertical_resolution = SimulatorSettings.LIDAR_DEFAULT_VERTICAL_RESOLUTION # deg_to_rad(LidarHeigth.text.to_float())
	NewSensor.horizontal_resolution = SimulatorSettings.LIDAR_DEFAULT_HORIZONTAL_RESOLUTION # deg_to_rad(LidarWidth.text.to_float())
	
	# Register to SensorList
	NewSensor.item_id = SensorList.add_item(NewSensor.name)
	vehicle.sensors.merge({NewSensor.name: NewSensor})

func _on_sensor_delete_pressed():
	var vehicle:SimulatorSettings.VehicleSetting = get_selected_vehicle()
	if vehicle == null:
		return
	
	var item:int = SensorList.get_selected_items()[0]
	var key:String = SensorList.get_item_text(item)
	vehicle.sensors.erase(key)
	SensorList.remove_item(item)

func _on_sensor_disable_pressed():
	var vehicle:SimulatorSettings.VehicleSetting = get_selected_vehicle()
	if vehicle == null:
		return
		
	var item:int = SensorList.get_selected_items()[0]
	var key:String = SensorList.get_item_text(item)
	if vehicle.sensors.has(key):
		var sensor := vehicle.sensors[key] as SimulatorSettings.Sensor
		sensor.enable = !sensor.enable
		
		if !sensor.enable:
			SensorList.set_item_custom_fg_color(item, Color(1.0, 1.0, 1.0, 0.2))
			SensorDisable.text = "ENABLE"
		else :
			SensorList.set_item_custom_fg_color(item, Color(1.0, 1.0, 1.0, 1.0))
			SensorDisable.text = "DISABLE"
	
func _on_sensor_list_item_selected(index):
	var vehicle:SimulatorSettings.VehicleSetting = get_selected_vehicle()
	if vehicle == null:
		return
	
	var key:String = SensorList.get_item_text(index)
	var sensor := vehicle.sensors[key] as SimulatorSettings.Sensor
	
	SensorType.select(sensor.type)
	SensorName.text = sensor.name
	PublishRate.text = str(sensor.hz)
	var sensor_position:Vector3 = ENU2EUS.eus_to_enu_v(sensor.location)
	var sensor_rotation:Basis = ENU2EUS.eus_to_enu_b(sensor.rotation)
	LocationX.text = str(sensor_position.x)
	LocationY.text = str(sensor_position.y)
	LocationZ.text = str(sensor_position.z)
	var euler:Vector3 = sensor_rotation.get_euler(EULER_ORDER_ZYX)
	RotationX.text = str(rad_to_deg(euler.x))
	RotationY.text = str(rad_to_deg(euler.y))
	RotationZ.text = str(rad_to_deg(euler.z))
	
	SensorDisable.text = "DISABLE" if sensor.enable else "ENABLE"
	CameraWitdh.text = str(sensor.resoultion.x)
	CameraHeight.text = str(sensor.resoultion.y)
	LidarVerticalFov.text = str(rad_to_deg(sensor.vertical_fov))
	LidarWidth.text = str(rad_to_deg(sensor.horizontal_resolution))
	LidarHeigth.text = str(rad_to_deg(sensor.vertical_resolution))

func get_selected_vehicle() -> SimulatorSettings.VehicleSetting:
	if !VehicleList.is_anything_selected():
		Notification.notify(" Select Veihcle ", Notification.NOTICE_TYPE.ALERT)
		return null
	
	if VehicleList.get_selected_items().size() > 1:
		Notification.notify(" Selected Multiple Veihcle ", Notification.NOTICE_TYPE.ALERT)
		return null
	
	return SimulatorSettings.VehicleList.get(VehicleList.get_item_text(VehicleList.get_selected_items()[0]))
	
func _on_vehicle_advanced_config_pressed():
	VehiclePopup.show()
func _on_sensor_advanced_config_pressed():
	SensorPopup.show()
func _on_vehicle_setup_close_pressed():
	VehiclePopup.hide()
func _on_sensor_setup_close_pressed():
	SensorPopup.hide()
