extends Window

class_name Console

@export var contents:RichTextLabel
signal text_submitted(text: String)
signal text_submitted_with_sysid(sys_id:int, text:String)

func append_contents(text: String):
	contents.append_text(text)

@onready var borderColor = get_node("BorderColor")
enum NOTIFY {NORMAL, ACCEPT, WARN, ALERT}
func notify(noty:NOTIFY):
	borderColor.notify(noty)

func _on_allways_on_top_button_toggled(button_pressed):
	always_on_top = button_pressed

func _on_close_requested():
	call_deferred("queue_free")

func _on_console_writer_text_submitted(new_text):
	text_submitted.emit(new_text)
	text_submitted_with_sysid.emit(name.to_int(), new_text)
