extends Window

@export var contents:RichTextLabel
signal text_submitted(text: String)

func append_contents(text: String):
	contents.append_text(text)
	pass

@onready var borderColor = get_node("BorderColor")

func notify(noty):
	borderColor.notify(noty)
	pass

func _on_allways_on_top_button_toggled(button_pressed):
	if button_pressed:
		always_on_top = true
		return
	
	always_on_top = false
	return

func _on_close_requested():
	call_deferred("queue_free")
	pass 

func _on_console_writer_text_submitted(new_text):
	text_submitted.emit(text_submitted, new_text)
	pass 
