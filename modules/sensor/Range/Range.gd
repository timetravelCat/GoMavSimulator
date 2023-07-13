extends Sensor

var property_saved_list:Dictionary = {
	"position":Vector3(0.0, 0.0, 0.0),
	"quaternion":Quaternion(0.0, 0.0, 0.0, 1.0),
	"hz":30.0,
	"enable":true,
	"distance":100.0,
}

@onready var raycast3D = $RayCast3D
@onready var rangePublisher = $RangePublisher

@export var distance:float = 100.0:
	set(_distance):
		distance = _distance
		if raycast3D:
			raycast3D.target_position = Vector3(distance, 0.0, 0.0)
		if rangePublisher:
			rangePublisher.max_range = distance
	
func _on_timeout():
	rangePublisher.publish((raycast3D.get_collision_point() - global_position).length())
