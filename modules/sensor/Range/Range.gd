extends RayCast3D

class_name RangeSensor

@export_category("Settings")
@export var publisher:RangePublisher
@export var distance:float = 100.0: 	# default distance
	set(_distance):
		target_position = Vector3(distance, 0.0, 0.0)
		publisher.max_range = distance
@export var hz:float = 10.0:			# default publish hz
	set(_hz):
		_timer.wait_time = 1.0 / hz

@export_category("Nodes")
@export var _timer:Timer

func _enter_tree():
	get_parent().connect("renamed", _on_renamed)
	_on_renamed()

func _on_renamed():
	if get_parent() and !get_parent().name.is_empty() and !name.is_empty():
		publisher.topic_name = get_parent().name + "/" + name	
		
func _on_publish_timer_timeout():
	publisher.publish((get_collision_point() - global_position).length())

# implement save load
