extends Control

@export var system_id:LineEdit
@export var component_id:LineEdit
@export var udp_portforward:OptionButton
@export var udp_portforward_port:LineEdit
@export var autoconnect:LineEdit
@export var autoconnect_list:ItemList

func _ready():
	# TODO implement initial values
	pass

func _on_console_connected_item_selected(index):
	match index:
		0:
			MavlinkSettings.open_console_when_connected = true
		1:
			MavlinkSettings.open_console_when_connected = false
	pass

func _on_console_disconnected_item_selected(index):
	match index:
		0:
			MavlinkSettings.close_console_when_disconnected = true
		1:
			MavlinkSettings.close_console_when_disconnected = false
	pass

func _on_open_console_pressed():
	MavlinkSettings.open_mavlink_shell.emit()
	pass

func _on_close_console_pressed():
	MavlinkSettings.close_mavlink_shell.emit()
	pass

func _on_joystick_control_item_selected(index):
	match index:
		0:
			MavlinkSettings.joystick_enabled.emit(true)
		1:
			MavlinkSettings.joystick_enabled.emit(false)
	pass

func _on_virtual_joystick_item_selected(index):
	match index:
		0:
			MavlinkSettings.virutal_joystick_enabled.emit(true)
		1:
			MavlinkSettings.virutal_joystick_enabled.emit(false)
	pass

func _on_system_id_text_submitted(new_text:String):
	if new_text.is_valid_int():
		MavlinkSettings.system_id_changed.emit(new_text.to_int())
	else:
		# reset LineEdit
		system_id.clear()
	pass # Replace with function body.

func _on_component_id_text_submitted(new_text:String):
	if new_text.is_valid_int():
		MavlinkSettings.component_id_changed.emit(new_text.to_int())
	else:
		# reset LineEdit
		component_id.clear()
	pass 

func _on_udp_portforward_item_selected(index):
	if udp_portforward_port.text.is_valid_int() == false:
		udp_portforward_port.clear()
		return
	match index:
		0:
			MavlinkSettings.udp_portforward_changed.emit(false, udp_portforward_port.text.to_int())
		1:
			MavlinkSettings.udp_portforward_changed.emit(true, udp_portforward_port.text.to_int())
	pass

func _on_udp_portforward_port_text_submitted(new_text:String):
	if new_text.is_valid_int():
		match udp_portforward.get_selected_id():
			0:
				MavlinkSettings.udp_portforward_changed.emit(false, new_text.to_int())
			1:
				MavlinkSettings.udp_portforward_changed.emit(true, new_text.to_int())
				pass
	else:
		udp_portforward_port.clear()
	pass

func _on_autoconnect_add_pressed():
	MavlinkSettings.auto_connect_added.emit(autoconnect.text)
	pass

func _on_autoconnect_remove_pressed():
	if autoconnect_list.is_anything_selected():
		var selected_items:PackedInt32Array = autoconnect_list.get_selected_items()
		for selected_item in selected_items:
			MavlinkSettings.auto_connect_removed.emit(autoconnect_list.get_item_text(selected_item))
	pass

func _on_autoconnect_enable_pressed():
	if autoconnect_list.is_anything_selected():
		var selected_items:PackedInt32Array = autoconnect_list.get_selected_items()
		for selected_item in selected_items:
			MavlinkSettings.auto_connect_enabled.emit(autoconnect_list.get_item_text(selected_item))
			autoconnect_list.set_item_custom_fg_color(selected_item, Color(1.0, 1.0, 1.0, 1.0))
			autoconnect_list.set_item_tooltip(selected_item, "enabled")
	pass

func _on_autoconnect_disable_pressed():
	if autoconnect_list.is_anything_selected():
		var selected_items:PackedInt32Array = autoconnect_list.get_selected_items()
		for selected_item in selected_items:
			MavlinkSettings.auto_connect_disabled.emit(autoconnect_list.get_item_text(selected_item))
			autoconnect_list.set_item_custom_fg_color(selected_item, Color(1.0, 1.0, 1.0, 0.2))
			autoconnect_list.set_item_tooltip(selected_item, "disabled")
	pass

