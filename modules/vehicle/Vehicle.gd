class_name Vehicle extends Node3D

# ===== default settings ===== #
@export var property_saved_list:Dictionary = {
	"name":"vehicle",
	"model_type":VehicleModel.MODEL_TYPE.MULTICOPTER,
	"pose_type":VehiclePose.POSE_TYPE.MAVLINK,
	"pose_name":"pose",
	"enable":true,
	"domain_id":0,
	"model_scale":1.0,
	"sys_id":1,
	"odometry_source":1, # 1 as initial value (ESTIMATION)
	"enable_model_publish":false,
	"enable_pose_publish":true,
	"pose_frame_id":"/map",
}

static var vehicle_scene:PackedScene = preload("res://modules/vehicle/Vehicle.tscn")

static func Create(vehicle_name:String, settings:Dictionary = {})->Vehicle:
	var vehicle = vehicle_scene.instantiate() as Vehicle
	vehicle.sensorContainer = vehicle.get_child(0)
	if not vehicle_name.is_empty():
		vehicle.name = vehicle_name
	for property in vehicle.property_saved_list:
		if property == "name" and not vehicle_name.is_empty():
			continue
		if property == "sensors": # sensors property is set after vehicle property are all set.
			continue
		if settings.has(property):
			vehicle.set(property, settings[property])
		else:
			vehicle.set(property, vehicle.property_saved_list[property])
	if settings.has("sensors"):
		var sensors = settings["sensors"] as Dictionary
		for sensor_name in sensors:
			var sensor_data = sensors[sensor_name]
			var sensor = vehicle.add_sensor(sensor_data["type"], sensor_name)
			# Set property of sensor without "type"
			for sensor_property in sensor_data:
				if sensor_property == "type":
					continue
					
				if typeof(sensor.get(sensor_property)) == Variant.Type.TYPE_VECTOR2 or \
					typeof(sensor.get(sensor_property)) == Variant.Type.TYPE_VECTOR2I or \
					typeof(sensor.get(sensor_property)) == Variant.Type.TYPE_VECTOR3 or \
					typeof(sensor.get(sensor_property)) == Variant.Type.TYPE_VECTOR3I or \
					typeof(sensor.get(sensor_property)) == Variant.Type.TYPE_QUATERNION:
						sensor.set(sensor_property, DefaultSettingMethods.string_to_vector(sensor_data[sensor_property]))
						continue
				
				sensor.set(sensor_property, sensor_data[sensor_property])
			# Set domain id of sensor 
			sensor.publisher.domain_id = vehicle.domain_id
			
	return vehicle

func ResetSettings():
	DefaultSettingMethods.reset_default_property(self, property_saved_list)
func LoadSettings():
	if not name.is_empty():
		DefaultSettingMethods.load_default_property(self, property_saved_list, get_setting_path())	
func SaveSettings():
	if not name.is_empty():
		DefaultSettingMethods.save_default_property(self, property_saved_list, get_setting_path())
func get_setting_path()->String:
	return name + "_setting.json"
func _ready():
	renamed.emit()

# ===== general configuration ====== #
@export_flags_3d_render var vehicle_layer
@export var enable:bool = true: set = set_enable
@export var domain_id:int: set = set_domain_id
# ===== model configuraiton ====== #
@export var model_type:VehicleModel.MODEL_TYPE : set = set_model_type
@export var modelPublisher:MarkerPublisher
@export var model_scale:float : set = set_model_scale, get = get_model_scale
@export var enable_model_publish:bool
# ===== pose configuration ===== #
@export var pose_type:VehiclePose.POSE_TYPE: set = set_pose_type
@export var posePublisher:PoseStampedPublisher
@export var sys_id:int : set = set_sys_id, get = get_sys_id
@export var odometry_source:GoMAVSDK.OdometrySource : set = set_odometry_source, get = get_odometry_source
@export var pose_name:String : set = set_pose_name, get = get_pose_name
@export var enable_pose_publish:bool
@export var pose_frame_id:String : set = set_pose_frame_id, get = get_pose_frame_id
# ===== sensor retreive functions ===== #
func get_sensors():
	return sensorContainer.get_children()
func get_sensor(sensor_name:String):
	return sensorContainer.find_child(sensor_name, false, false)
func add_sensor(sensor_type:Sensor.SENSOR_TYPE, sensor_name:String)->Sensor:
	if sensorContainer.has_node(sensor_name):
		return null
	return Sensor.Create(self, sensor_type, sensor_name)
func remove_sensor(sensor_name:String):
	var sensor:Sensor = get_sensor(sensor_name)
	if not sensor:
		return
	sensorContainer.remove_child(sensor)
	sensor.free()
# ===== getter, setters ====== #
func set_enable(_enable):
	enable = _enable
	pose._set_enable(_enable)
	model._set_enable(_enable)
	for sensor in sensorContainer.get_children():
		sensor.enable = _enable
func set_domain_id(_domain_id):
	domain_id = _domain_id
	pose._set_domain_id(_domain_id)
	for sensor in sensorContainer.get_children():
		sensor.publisher.domain_id = _domain_id
	modelPublisher.domain_id = _domain_id
	posePublisher.domain_id = _domain_id
func set_model_type(_model_type):
	model_type = _model_type
	VehicleModel.Create(self, _model_type)
	recursive_set_visual_layer_vehicle(model)
func set_model_scale(_model_scale):
	model_scale = _model_scale
	model._set_scale(_model_scale)
func get_model_scale()->float:
	return model._get_scale()
func set_pose_type(_pose_type):
	pose_type = _pose_type
	VehiclePose.Create(self, _pose_type)
	pose.connect("pose_update", _on_pose_updated)
	pose.connect("armed_updated", _on_armed_updated)
func set_sys_id(_sys_id):
	sys_id = _sys_id
	pose._set_sys_id(sys_id)
func set_odometry_source(_odometry_source):
	odometry_source = _odometry_source
	pose._set_odometry_source(_odometry_source)
func set_pose_name(_pose_name):
	pose_name = _pose_name
	pose.name = _pose_name
func set_pose_frame_id(_pose_frame_id):
	posePublisher.frame_id = _pose_frame_id
	pose_frame_id = _pose_frame_id
func get_pose_frame_id()->String:
	return posePublisher.frame_id
func get_sys_id()->int:
	return pose._get_sys_id()
func get_odometry_source()->GoMAVSDK.OdometrySource:
	return pose._get_odometry_source()
func get_pose_name()->String:
	return pose.name
func recursive_set_visual_layer_vehicle(vehicle_child:Node):
	var visualinstance = vehicle_child as VisualInstance3D
	if visualinstance: # in case of meshinstance, 
		visualinstance.layers = vehicle_layer
	for child in vehicle_child.get_children():
		recursive_set_visual_layer_vehicle(child)
func _on_renamed():
	modelPublisher.topic_name = name + "_model"
	posePublisher.topic_name = name + "_pose"
func _on_pose_updated(pos:Vector3, quat:Quaternion):
	if enable_pose_publish:
		posePublisher.publish(pos, quat)
	if enable_model_publish:
		modelPublisher.publish(pos, quat)
func _on_armed_updated(armed):
	if model:
		model.armed = armed
# ===== ineternal variable ====== #
var sensorContainer:Node3D
var pose:VehiclePose
var model:VehicleModel
