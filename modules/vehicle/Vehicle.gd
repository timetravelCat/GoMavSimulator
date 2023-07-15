class_name Vehicle extends Node3D

# ===== default settings ===== #
@export var property_saved_list:Dictionary = {
	"name":"vehicle",
	"enable":true,
	"domain_id":0,
	"model_type":VehicleModel.MODEL_TYPE.MULTICOPTER,
	"pose_type":VehiclePose.POSE_TYPE.MAVLINK,
	"enable_model_publish":false,
	"enable_pose_publish":true,
}

static var vehicle_scene:PackedScene = preload("res://modules/vehicle/Vehicle.tscn")

static func Create(vehicle_name:String)->Vehicle:
	var vehicle:Vehicle = vehicle_scene.instantiate()
	vehicle.name = vehicle_name
	return vehicle

# TODO Load - Save of : Vehicle, VehiclePose, VehicleModel, Sensors
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

#func _exit_tree():
#	SaveSettings()

# ===== general configuration ====== #
@export_flags_3d_render var vehicle_layer
@export var enable:bool = true: set = set_enable
@export var domain_id:int: set = set_domain_id
# ===== model configuraiton ====== #
@export var model_type:VehicleModel.MODEL_TYPE : set = set_model_type
@export var modelPublisher:MarkerPublisher
@export var enable_model_publish:bool
# ===== pose configuration ===== #
@export var pose_type:VehiclePose.POSE_TYPE: set = set_pose_type
@export var posePublisher:PoseStampedPublisher
@export var enable_pose_publish:bool
# ===== sensor retreive functions ===== #
@onready var sensorContainer:Node3D = $SensorContainer
func get_sensors():
	return sensorContainer.get_children()
func get_sensor(sensor_name:String):
	return sensorContainer.find_child(sensor_name, false, false)
func add_sensor(sensor_name:String, sensor_type:Sensor.SENSOR_TYPE):
	if sensorContainer.has_node(sensor_name):
		return
	Sensor.Create(self, sensor_type)
	# TOOD load sensor settings
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
var model:VehicleModel
func set_model_type(_model_type):
	model_type = _model_type
	VehicleModel.Create(self, _model_type)
	recursive_set_visual_layer_vehicle(model)
	# TODO load model
var pose:VehiclePose
func set_pose_type(_pose_type):
	pose_type = _pose_type
	VehiclePose.Create(self, _pose_type)
	pose.connect("pose_update", _on_pose_updated)
	# TODO load pose 
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
