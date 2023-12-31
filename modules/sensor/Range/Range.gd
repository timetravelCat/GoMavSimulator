class_name RangeSensor extends Sensor

@export var property_saved_list:Dictionary = {
	"position":Vector3(0.0, 0.0, 0.0),
	"quaternion":Quaternion(0.0, 0.0, 0.0, 1.0),
	"frame_id":"/map",
	"hz":30.0,
	"enable":true,
	"distance":100.0,
}

@onready var raycast3D = $RayCast3D
@export var rangePublisher:RangePublisher

@export var distance:float = 100.0:
	set(_distance):
		distance = _distance
		if raycast3D:
			raycast3D.target_position = Vector3(distance, 0.0, 0.0)
		if rangePublisher:
			rangePublisher.max_range = distance

func _ready():
	super._ready()
	distance = distance

func _on_timeout():
	if raycast3D.is_colliding():
		rangePublisher.publish((raycast3D.get_collision_point() - global_position).length())
	else:
		rangePublisher.publish(INF)
