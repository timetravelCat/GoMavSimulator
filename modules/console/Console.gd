class_name Console extends Window

@export_category("Console")
@export var write_to_contents:bool
@export var normal:Color
@export var accept:Color
@export var warning:Color
@export var alert:Color

signal text_submitted(text: String)
signal text_submitted_with_sysid(sys_id:int, text:String)
func append_contents(text: String):
	contents.append_text(text)
enum NOTIFY {NORMAL, ACCEPT, WARN, ALERT}
func notify(noty:NOTIFY):
	_notify(noty)

func _on_allways_on_top_button_toggled(button_pressed):
	always_on_top = button_pressed

func _on_console_writer_text_submitted(new_text):
	if write_to_contents:
		contents.append_text(">" + new_text + "\n")
	
	text_submitted.emit(new_text)
	text_submitted_with_sysid.emit(name.to_int(), new_text)

func _set_shader_progress(progress: float):
	borderColor.material.set_shader_parameter("progress", progress)

func _on_clear_button_pressed():
	contents.clear()

func _on_close_requested():
	call_deferred("queue_free")

func _ready():
	notify(NOTIFY.ACCEPT)

func _notify(noty:NOTIFY):
	var material_color:Color
	match noty:
		NOTIFY.NORMAL:
			material_color = normal
		NOTIFY.ACCEPT:
			material_color = accept
		NOTIFY.WARN:
			material_color = warning
		NOTIFY.ALERT:
			material_color = alert
	borderColor.material.set_shader_parameter("color", material_color)
	var tween = create_tween()
	tween.tween_method(_set_shader_progress, 0.0, 1.0, 1.0)

@onready var contents:RichTextLabel = $VerticalSplit/ContentsPanel/ContentsContainer/Contents
@onready var borderColor = get_node("BorderColor")
