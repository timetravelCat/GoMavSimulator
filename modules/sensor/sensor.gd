class_name Sensor extends Node3D

signal sensor_enabled(enable:bool)

@export_category("Common Settings")
@export var type:Vehicle.SENSOR_TYPE
@export var publisher:Publisher:
	set(_publisher):
		publisher = _publisher
		_on_renamed()
@export var hz:float = 10.0:
	set(_hz):
		timer.wait_time = 1.0 / _hz
		hz = _hz
@export var enable:bool = true:
	set(_enable):
		if _enable:
			timer.start()
			show()
		else:
			timer.stop()
			hide()
		enable = _enable
		sensor_enabled.emit(enable)

var timer:Timer

func _init():
	timer = Timer.new()
	timer.autostart = true
	add_child(timer)

func _enter_tree():
	get_parent().connect("renamed", _on_renamed)
	connect("renamed", _on_renamed)
	_on_renamed()

func _on_renamed():
	if get_parent() and !get_parent().name.is_empty() and !name.is_empty() and publisher:
		publisher.topic_name = get_parent().name + "/" + name	
