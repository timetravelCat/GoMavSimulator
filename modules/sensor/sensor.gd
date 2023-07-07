extends Node3D

class_name Sensor

@export_category("Common Settings")
@export var type:Vehicle.SENSOR_TYPE
@export var publisher:Publisher
@export var hz:float = 10.0:			# default publish hz
	set(_hz):
		timer.wait_time = 1.0 / hz
		hz = _hz
@export var enable:bool = true:
	set(_enable):
		if _enable:
			timer.start()
		else:
			timer.stop()
		enable = _enable

var timer:Timer

func _init():
	timer = Timer.new()
	timer.autostart = true
	add_child(timer)

func _enter_tree():
	get_parent().connect("renamed", _on_renamed)
	_on_renamed()

func _on_renamed():
	if get_parent() and !get_parent().name.is_empty() and !name.is_empty() and publisher:
		publisher.topic_name = get_parent().name + "/" + name	