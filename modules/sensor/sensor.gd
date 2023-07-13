class_name Sensor extends Node3D

@export_category("Common Settings")
@export var type:SensorSettings.SENSOR_TYPE
@export var publisher:Publisher
@export var hz:float = 10.0: set = set_hz
@export var enable:bool = true: set = set_enable

signal sensor_enabled(enable:bool)
signal sensor_renamed(vehicle_name:String, sensor_name:String)

@onready var timer:Timer = $Timer

func _ready():
	set_hz(hz);
	set_enable(enable)
	
	get_parent().connect("renamed", _rename_sensor_publisher)
	_rename_sensor_publisher()
	
func _rename_sensor_publisher():
	if get_parent() and !get_parent().name.is_empty() and !name.is_empty() and publisher:
		publisher.topic_name = get_parent().name + "/" + name	
		emit_signal("sensor_renamed", get_parent().name, name)

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
