extends RichTextLabel

@export var write_to_contents:bool = true

func _on_clear_button_pressed():
	clear()
	pass # Replace with function body.

func _on_console_writer_text_submitted(new_text):
	if write_to_contents:
		append_text(">" + new_text + "\n")
	pass # Replace with function body.
