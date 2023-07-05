extends Node3D

class_name Vehicle

# ===== general configuration ====== #
var item_id:int = -1 # itemlist control id
var enable:bool = false:
	set = set_enable
var domain_id:int = 0:
	set = set_domain_id
# ===== model configuraiton ====== #
enum MODEL_TYPE {MULTICOPTER, ROVER, PLANE}
var model_list:Array = [
	preload("res://modules/vehicle/model/drone.glb"),
	preload("res://modules/vehicle/model/rover.glb"),
	preload("res://modules/vehicle/model/plane.glb")]
var model_type:MODEL_TYPE = MODEL_TYPE.MULTICOPTER:
	set = set_model_type
var model:Node3D = null # contain vehicle mesh
# ===== pose configuration ====== #
enum POSE_TYPE {MAVLINK, ROS2, USER}
var pose_list:Array = [
	preload("res://modules/vehicle/pose/pose_mavlink.tscn"),
	preload("res://modules/vehicle/pose/pose_ros2.tscn"),
	preload("res://modules/vehicle/pose/pose_user.tscn")]
var pose_type:POSE_TYPE = POSE_TYPE.MAVLINK:
	set = set_pose_type
var pose = null
# ===== sensor configuraiton ====== #
enum SENSOR_TYPE {RANGE, LIDAR, RGB_CAMERA, DEPTH_CAMERA} 
var sensor_list:Array = [
	preload("res://modules/sensor/Range/Range.tscn")]
var sensors:Array # sensors are all inherit from Node3D, must have publisher property
# ================================= #
func set_enable(_enable):
	if enable and !_enable:
		if model:
			model.queue_free()
		if pose:
			pose.queue_free()
		for sensor in sensors:
			sensor.queue_free()
			
	if !enable and _enable or model == null or pose == null:
		if model:
			model.queue_free()
		model = model_list[model_type].instantiate()	
		add_child(model)
		if pose:
			pose.queue_free()
		pose = pose_list[pose_type].instantiate()	
		add_child(pose)
		
	enable = _enable
func set_domain_id(_domain_id):
	if not enable:
		return
	var pose_ros2 = pose as PoseStampedSubscriber
	if pose_ros2:
		pose_ros2.domain_id = _domain_id
	for sensor in sensors:
		sensor.publisher.domain_id = _domain_id # sensor 
func set_model_type(_model_type):
	if not enable:
		return
	if model_type != _model_type or model == null:
		if model:
			model.queue_free()
		model = model_list[_model_type].instantiate()	
		add_child(model)
		model_type = _model_type
func set_pose_type(_pose_type):
	if not enable:
		return
	if pose_type != _pose_type or pose == null:
		if pose:
			pose.queue_free()
		pose = pose_list[_pose_type].instantiate()	
		add_child(pose)
		pose_type = _pose_type
# Sensor retreive methods
func get_sensor(_sensor_name:String):
	return find_child(_sensor_name)
func add_sensor(_sensor_name:String, _sensor_type:SENSOR_TYPE):
	if get_sensor(_sensor_name):
		Notification.notify("Exist " + _sensor_name + " found on " + name, Notification.NOTICE_TYPE.ALERT)
		return null
	var sensor = sensor_list[_sensor_type].instanciate()
	sensor.name = _sensor_name	
	add_child(sensor)
func remove_sensor(_sensor_name:String):
	if get_sensor(_sensor_name):
		remove_child(get_sensor(_sensor_name))
# ================================= # 
# implement save_load

