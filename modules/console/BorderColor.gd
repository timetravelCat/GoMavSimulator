extends ColorRect

@export var normal:Color
@export var accept:Color
@export var warning:Color
@export var alert:Color

func set_shader_progress(progress: float):
	material.set_shader_parameter("progress", progress)
	pass

func notify(type: Console.NOTIFY):
	var material_color = normal
	match type:
		Console.NOTIFY.ACCEPT:
			material_color = accept
		Console.NOTIFY.WARN:
			material_color = warning
		Console.NOTIFY.ALERT:
			material_color = alert
			
	material.set_shader_parameter("color", material_color)
	var tween = create_tween()
	tween.tween_method(set_shader_progress, 0.0, 1.0, 1.0)
	pass
