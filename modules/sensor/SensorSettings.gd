class_name SensorSettings extends Node

enum SENSOR_TYPE {RANGE, LIDAR, RGB_CAMERA, DEPTH_CAMERA} 

static var sensor_type_string:PackedStringArray = [
	"Range(ToF)",
	"Lidar",
	"RGB Camera",
	"Depth Camera"
]

static func Create(sensor_type:SENSOR_TYPE)->Node3D:
	match sensor_type:
		SENSOR_TYPE.RANGE:
			return load("res://modules/sensor/Range/Range.tscn").instantiate()
		SENSOR_TYPE.LIDAR:
			return load("res://modules/sensor/Range/Lidar.tscn").instantiate()
		SENSOR_TYPE.RGB_CAMERA:
			return load("res://modules/sensor/Range/CameraRGB.tscn").instantiate()
		SENSOR_TYPE.DEPTH_CAMERA:
			return load("res://modules/sensor/Range/CameraDepth.tscn").instantiate()
	return null
