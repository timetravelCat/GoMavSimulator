extends Sensor

@onready var raycast3D = $RayCast3D
@onready var rangePublisher = $RangePublisher

@export var distance:float = 100.0: 	# default distance
	set(_distance):
		get_node("RayCast3D").target_position = Vector3(distance, 0.0, 0.0)
		get_node("RangePublisher").max_range = distance

func _ready():
	timer.timeout.connect(_on_timeout)
	
func _on_timeout():
	rangePublisher.publish((raycast3D.get_collision_point() - global_position).length())
