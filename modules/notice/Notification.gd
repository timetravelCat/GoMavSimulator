# "Notification" : A singletone node controlling simple string popup.
extends Node

@export var notice_scene:PackedScene
@export var notice_duration:float

enum NOTICE_TYPE {ALERT, WARNING, NORMAL}

func notify(contents:String, type:NOTICE_TYPE = NOTICE_TYPE.NORMAL, duration:float = notice_duration):
	var notice = notice_scene.instantiate()
	get_parent().add_child(notice)
	notice.set_text(contents)
	match type:
		NOTICE_TYPE.ALERT:
			notice.set_color(Color("ORANGE_RED"))
		NOTICE_TYPE.WARNING:
			notice.set_color(Color("GOLD"))
		NOTICE_TYPE.NORMAL:
			notice.set_color(Color("LIME"))
	
	notice.notify(duration)

func _ready():
	# Global notification - joystick connection
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _on_joy_connection_changed(device:int, connected:bool):
	if connected:
		notify("Joystick " + str(device) + "  connected", NOTICE_TYPE.NORMAL)
	else:
		notify("Joystick " + str(device) + "  disconnected", NOTICE_TYPE.WARNING)
