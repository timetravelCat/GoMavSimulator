class_name Sensor extends Node3D

enum SENSOR_TYPE {RANGE, LIDAR, RGB_CAMERA, DEPTH_CAMERA} 

static var SENSOR_TYPE_STRING:PackedStringArray = [
	"Range(ToF)",
	"Lidar",
	"RGB Camera",
	"Depth Camera"
]

var vehicle:Vehicle

static func Create(_vehicle:Vehicle, sensor_type:SENSOR_TYPE)->Sensor:
	var sensor:Sensor
	match sensor_type:
		SENSOR_TYPE.RANGE:
			sensor = load("res://modules/sensor/Range/Range.tscn").instantiate()
		SENSOR_TYPE.LIDAR:
			sensor = load("res://modules/sensor/Range/Lidar.tscn").instantiate()
		SENSOR_TYPE.RGB_CAMERA:
			sensor = load("res://modules/sensor/Range/CameraRGB.tscn").instantiate()
		SENSOR_TYPE.DEPTH_CAMERA:
			sensor = load("res://modules/sensor/Range/CameraDepth.tscn").instantiate()
	sensor.vehicle = _vehicle
	_vehicle.sensorContainer.add_child(sensor)
	_vehicle.connect("renamed", _rename_sensor_publisher)
	return null

@export_category("Common Settings")
@export var type:SENSOR_TYPE
@export var publisher:Publisher
@export var hz:float = 10.0: set = set_hz
@export var enable:bool = true: set = set_enable

signal sensor_enabled(enable:bool)
signal sensor_renamed(vehicle_name:String, sensor_name:String)

@onready var timer:Timer = $Timer

func _ready():
	set_hz(hz);
	set_enable(enable)
	_rename_sensor_publisher()
	
func _rename_sensor_publisher():
	if vehicle and !vehicle.name.is_empty() and !name.is_empty() and publisher:
		publisher.topic_name = vehicle.name + "/" + name	
		emit_signal("sensor_renamed", vehicle.name, name)

func set_hz(_hz):
	if timer:
		timer.wait_time = 1.0 / _hz
	hz = _hz
	
func set_enable(_enable):
	enable = _enable
	if _enable:
		if timer:
			timer.call_deferred("start")
		show()
	else:
		if timer:
			timer.call_deferred("stop")
		hide()
	
	sensor_enabled.emit(enable)
