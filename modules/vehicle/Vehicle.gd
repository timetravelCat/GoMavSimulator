extends Node3D

class_name Vehicle

# ===== general configuration ====== #
var enable:bool = true:
	set = set_enable
var domain_id:int = 0:
	set = set_domain_id
# ===== model configuraiton ====== #
@export_flags_3d_render var vehicle_layer
enum MODEL_TYPE {MULTICOPTER, ROVER, PLANE}
const MODEL_TYPE_STRING:PackedStringArray = [
	"MultiCopter",
	"Rover",
	"Plane"]
static var model_list:Array = [
	preload("res://modules/vehicle/model/drone.glb"),
	preload("res://modules/vehicle/model/rover.glb"),
	preload("res://modules/vehicle/model/plane.glb")]
var model_type:MODEL_TYPE = MODEL_TYPE.MULTICOPTER:
	set = set_model_type
var model:Node3D = null # contain vehicle mesh
# ===== pose configuration ====== #
enum POSE_TYPE {MAVLINK, ROS2, USER}
const POSE_TYPE_STRING:PackedStringArray = [
	"MAVLINK",
	"ROS2",
	"USER"]
static var pose_list:Array = [
	preload("res://modules/vehicle/pose/pose_mavlink.tscn"),
	preload("res://modules/vehicle/pose/pose_ros2.tscn"),
	preload("res://modules/vehicle/pose/pose_user.tscn")]
var pose_type:POSE_TYPE = POSE_TYPE.MAVLINK:
	set = set_pose_type
var pose = null
# ===== sensor configuraiton ====== #
enum SENSOR_TYPE {RANGE, LIDAR, RGB_CAMERA, DEPTH_CAMERA} 
const SENSOR_TYPE_STRING:PackedStringArray = [
	"Range(ToF)",
	"Lidar",
	"RGB Camera",
	"Depth Camera"]
static var sensor_list:Array = [
	preload("res://modules/sensor/Range/Range.tscn"),
	preload("res://modules/sensor/Lidar/Lidar.tscn"),
	preload("res://modules/sensor/CameraRGB/CameraRGB.tscn")]
var sensors:Array # sensors are all inherit from Sensor class
# ===== getter, setters ====== #
func _init():
	model = model_list[model_type].instantiate()
	add_child(model)
	pose = pose_list[pose_type].instantiate()	
	add_child(pose)
	set_domain_id(domain_id)
func set_enable(_enable):
	enable = _enable
	if enable:
		model.show()
	else:
		model.hide()
	for sensor in sensors:
		sensor.enable = _enable
func set_domain_id(_domain_id):
	var pose_ros2 = pose as PoseStampedSubscriber
	if pose_ros2:
		pose_ros2.domain_id = _domain_id
	for sensor in sensors:
		sensor.publisher.domain_id = _domain_id # sensor 
	domain_id = _domain_id
func set_model_type(_model_type):
	model_type = _model_type
	var _model = model_list[model_type].instantiate()
	# copy saved settings from previous model
	_model.name = model.name
	_model.scale = model.scale
	if not enable:
		_model.hide()
	remove_child(model)
	model.free()
	model = _model
	add_child(model)
	recursive_set_visual_layer_vehicle(model)
	
func set_pose_type(_pose_type):
	pose_type = _pose_type
	var _pose = pose_list[pose_type].instantiate()
	# copy saved settings from previous pose
	_pose.name = pose.name
	
	var _pose_mavlink = _pose as GoMAVSDK
	if _pose_mavlink:
		_pose_mavlink.sys_enable = enable
		var pose_mavlink = pose as GoMAVSDK
		if pose_mavlink:
			_pose_mavlink.sys_id = pose_mavlink.sys_id
			_pose_mavlink.odometry_source = pose_mavlink.odometry_source
			
	var _pose_ros2 = _pose as PoseStampedSubscriber
	if _pose_ros2:
		_pose_ros2.domain_id = domain_id
	# copy settings of ros2dds
	remove_child(pose)
	pose.free()
	pose = _pose
	add_child(pose)
# ===== sensor retreive functions ===== #
func get_sensor(_sensor_name:String):
	if _sensor_name == model.name or _sensor_name == pose.name:
		return null
	return find_child(_sensor_name, false, false)
func add_sensor(_sensor_name:String, _sensor_type:SENSOR_TYPE):
	if _sensor_name == model.name or _sensor_name == pose.name:
		Notification.notify("Unvalid sensor name requested. change sensor name", Notification.NOTICE_TYPE.ALERT)
		return null
	if get_sensor(_sensor_name):
		Notification.notify("Sensor name exists", Notification.NOTICE_TYPE.ALERT)
		return null
	
	var sensor = sensor_list[_sensor_type].instantiate()
	sensor.name = _sensor_name
	
	# set default settings
	match _sensor_type:
		SENSOR_TYPE.RANGE:
			sensor.distance = SimulatorSettings.def_range_distance
		SENSOR_TYPE.LIDAR:
			sensor.distance = SimulatorSettings.def_lidar_distance
			sensor.vertical_fov = SimulatorSettings.def_lidar_vertical_fov
			sensor.resolution = SimulatorSettings.def_lidar_resolution
		SENSOR_TYPE.RGB_CAMERA:
			sensor.resolution = SimulatorSettings.def_rgb_camera_resolution
			sensor.compressed = SimulatorSettings.def_rgb_camera_compressed
			sensor.fov = SimulatorSettings.def_rgb_camera_fov
		# TODO other sensor default setting

	sensors.append(sensor)
	add_child(sensor)
	return sensor
func remove_sensor(_sensor_name:String):
	if not get_sensor(_sensor_name):
		return
	var sensor = get_sensor(_sensor_name)
	remove_child(sensor)
	sensors.erase(sensor)
	sensor.free()
# ================================= # 
# implement save_load

func recursive_set_visual_layer_vehicle(vehicle_child:Node):
	for child in vehicle_child.get_children():
		recursive_set_visual_layer_vehicle(child)
		var visualinstance = child as VisualInstance3D
		if visualinstance: # in case of meshinstance, 
			visualinstance.layers = vehicle_layer
