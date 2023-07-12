# "Notification" : A singletone node controlling simple string popup.
extends Node

var scene:PackedScene = ResourceLoader.load("res://modules/notice/notice.tscn")
enum NOTICE_TYPE {ALERT, WARNING, NORMAL}

func notify(contents:String, type:NOTICE_TYPE = NOTICE_TYPE.NORMAL, duration:float = 2.0):
	var notice = scene.instantiate()
	add_child(notice)
	notice.set_text(contents)
	
	match type:
		NOTICE_TYPE.ALERT:
			notice.set_color(Color("ORANGE_RED"))
		NOTICE_TYPE.WARNING:
			notice.set_color(Color("GOLD"))
		NOTICE_TYPE.NORMAL:
			notice.set_color(Color("LIME"))
	
	notice.notify(duration)
	pass

func _ready():
	# Regigter global notification 
	Input.joy_connection_changed.connect(_on_joy_connection_changed) # joystick connection

func _on_joy_connection_changed(device:int, connected:bool):
	if connected:
		notify("Joystick " + str(device) + "  connected", NOTICE_TYPE.NORMAL)
	else:
		notify("Joystick " + str(device) + "  disconnected", NOTICE_TYPE.WARNING)
