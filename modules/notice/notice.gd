class_name Notice extends Control

@onready var BackGround:ColorRect = $BackGround
@onready var colorRect:ColorRect = $VBoxContainer/ColorRect
@onready var label:Label = $VBoxContainer/Label
@onready var container:VBoxContainer = $VBoxContainer

func set_color(color:Color):
	colorRect.color = color
	pass

func set_text(text:String):
	label.text = text
	pass

func set_color_scale(value:float):
	colorRect.scale.x = value
	BackGround.size = container.size

func set_object_scale(value:float):
	container.scale.x = value
	
var tween:Tween

func notify(duration:float):
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_method(set_color_scale, 1.0, 0.0, duration)
	tween.tween_method(set_object_scale, 1.0, 0.0, 0.1)
	tween.tween_callback(queue_free)
	pass
