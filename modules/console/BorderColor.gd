extends ColorRect

@export var normal:Color
@export var accept:Color
@export var warning:Color
@export var alert:Color

enum NOTIFY {NORMAL, ACCEPT, WARN, ALERT}

func set_shader_progress(progress: float):
	material.set_shader_parameter("progress", progress)
	pass

func notify(type: NOTIFY):
	var material_color = normal
	match type:
		NOTIFY.ACCEPT:
			material_color = accept
		NOTIFY.WARN:
			material_color = warning
		NOTIFY.ALERT:
			material_color = alert
			
	material.set_shader_parameter("color", material_color)
	var tween = create_tween()
	tween.tween_method(set_shader_progress, 0.0, 1.0, 1.0)
	pass
