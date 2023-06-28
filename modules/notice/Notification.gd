# "Notification" : A singletone node controlling simple string popup.
extends Node

var scene:PackedScene = ResourceLoader.load("res://modules/notice/notice.tscn")
enum NOTICE_TYPE {ALERT, WARNING, NORMAL}

func notify(contents:String, type:NOTICE_TYPE = NOTICE_TYPE.NORMAL, duration:float = 2.0):
	var notice:Notice = scene.instantiate()
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
