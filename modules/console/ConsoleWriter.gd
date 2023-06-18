extends LineEdit

var history := PackedStringArray()
var history_location := 0

@onready var historyMenu:MenuButton = get_node("../HistoryMenu")

func _on_text_submitted(command):
	clear()
	
	# Remove if same command is allready exists in history
	var _idx_prev = history.find(command)
	if _idx_prev >= 0:
		history.remove_at(_idx_prev)
	
	historyMenu.add_item(command)
	history.append(command)
	history_location = history.size() - 1 # reset history location to recent
	pass

func _on_gui_input(event):
	if history.is_empty():
		return
	
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_UP:
				text = history[history_location]
				if history_location > 0:
					history_location -= 1
			elif event.keycode == KEY_DOWN:
				text = history[history_location]
				if history_location < history.size() - 1:
					history_location += 1
	pass
