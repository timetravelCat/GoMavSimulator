extends Node

enum SENSOR_TYPE {RANGE, LIDAR, RGB_CAMERA, DEPTH_CAMERA} 

var sensor_type_string:PackedStringArray = [
	"Range(ToF)",
	"Lidar",
	"RGB Camera",
	"Depth Camera"
]
	
var sensor_list:Array[PackedScene] = [
	preload("res://modules/sensor/Range/Range.tscn"),
	preload("res://modules/sensor/Lidar/Lidar.tscn"),
	preload("res://modules/sensor/CameraRGB/CameraRGB.tscn"),
	preload("res://modules/sensor/CameraDepth/CameraDepth.tscn")]
	
func Create(sensor_type:SENSOR_TYPE)->Node3D:
	return sensor_list[sensor_type].instantiate()
