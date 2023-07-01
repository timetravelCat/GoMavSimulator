extends Control

@export var console_connect:OptionButton
@export var console_disconnect:OptionButton
@export var joystick_control:OptionButton
@export var virtual_joystick:OptionButton
@export var system_id:LineEdit
@export var component_id:LineEdit
@export var udp_portforward:OptionButton
@export var udp_portforward_port:LineEdit
@export var autoconnect:LineEdit
@export var autoconnect_list:ItemList

func reset_to_default():
	console_connect.select(0)
	console_connect.item_selected.emit(0)
	
	console_disconnect.select(0)
	console_disconnect.item_selected.emit(0)
	
	joystick_control.select(1)
	joystick_control.item_selected.emit(1)
	
	virtual_joystick.select(1)
	virtual_joystick.item_selected.emit(1)
	
	system_id.text = str(MavlinkSettings.DEFAULT_SYS_ID)
	system_id.text_submitted.emit(system_id.text)
	
	component_id.text = str(MavlinkSettings.DEFAULT_COMP_ID)
	component_id.text_submitted.emit(component_id.text)
	
	udp_portforward.select(0)
	udp_portforward_port.text = str(MavlinkSettings.DEFAULT_UDP_PORTFORWARD_PORT)
	MavlinkSettings.udp_portforward_changed.emit(false, MavlinkSettings.DEFAULT_UDP_PORTFORWARD_PORT)
	
	# remove all items in list
	while autoconnect_list.item_count > 0:
		autoconnect_list.select(0)
		_on_autoconnect_remove_pressed()
	
	# Add default item 
	for key in MavlinkSettings.DEFAULT_AUTOCONNECT_LIST:
		var autoConnect:MavlinkSettings.AutoConnect = MavlinkSettings.AutoConnect.new()
		autoConnect.index = autoconnect_list.add_item(key)
		autoConnect.enabled = MavlinkSettings.DEFAULT_AUTOCONNECT_LIST[key]
		MavlinkSettings.AutoConnectList.merge({key:autoConnect})
		if !autoConnect.enabled:
			autoconnect_list.set_item_custom_fg_color(autoConnect.index, Color(1.0, 1.0, 1.0, 0.2))
	MavlinkSettings.auto_connect_list_changed.emit(true)

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
		Notification.notify(" Unvalid system id ", Notification.NOTICE_TYPE.ALERT)
		system_id.clear()

func _on_component_id_text_submitted(new_text:String):
	if !new_text.is_valid_int():
		Notification.notify(" Unvalid comp id ", Notification.NOTICE_TYPE.ALERT)
		component_id.clear()
		return
		
	MavlinkSettings.component_id_changed.emit(new_text.to_int())

func _on_udp_portforward_item_selected(index):
	if udp_portforward_port.text.is_valid_int() == false:
		Notification.notify(" Unvalid port ", Notification.NOTICE_TYPE.ALERT)
		udp_portforward_port.clear()
		return
		
	match index:
		0:
			MavlinkSettings.udp_portforward_changed.emit(false, udp_portforward_port.text.to_int())
		1:
			MavlinkSettings.udp_portforward_changed.emit(true, udp_portforward_port.text.to_int())

func _on_udp_portforward_port_text_submitted(new_text:String):
	if !new_text.is_valid_int():
		Notification.notify(" Unvalid port ", Notification.NOTICE_TYPE.ALERT)
		udp_portforward_port.clear()
		return 
		
	match udp_portforward.get_selected_id():
		0:
			MavlinkSettings.udp_portforward_changed.emit(false, new_text.to_int())
		1:
			MavlinkSettings.udp_portforward_changed.emit(true, new_text.to_int())
			pass

func _on_autoconnect_add_pressed():
	if autoconnect.text.is_empty():
		Notification.notify(" Empty Connection Address ", Notification.NOTICE_TYPE.ALERT)
		return 
		
	if MavlinkSettings.AutoConnectList.has(autoconnect.text):
		Notification.notify(" Connection Address Already Exist ", Notification.NOTICE_TYPE.WARNING)
		return 
	# TODO Check about string by using REGEX?
	
	var autoConnect:MavlinkSettings.AutoConnect = MavlinkSettings.AutoConnect.new()
	autoConnect.index = autoconnect_list.add_item(autoconnect.text)
	autoConnect.enabled = true
	MavlinkSettings.AutoConnectList.merge({autoconnect.text:autoConnect})
	MavlinkSettings.auto_connect_list_changed.emit(false)

func _on_autoconnect_remove_pressed():
	if !autoconnect_list.is_anything_selected():
		Notification.notify(" Select AutoConnect item ", Notification.NOTICE_TYPE.WARNING)
		return
	
	var selected_item:int = autoconnect_list.get_selected_items()[0]
	MavlinkSettings.AutoConnectList.erase(autoconnect_list.get_item_text(selected_item))
	autoconnect_list.remove_item(selected_item)
	MavlinkSettings.auto_connect_list_changed.emit(true)

func _on_autoconnect_enable_pressed():
	if !autoconnect_list.is_anything_selected():
		Notification.notify(" Select AutoConnect item ", Notification.NOTICE_TYPE.WARNING)
		return
	
	var selected_item:int = autoconnect_list.get_selected_items()[0]
	MavlinkSettings.AutoConnectList[autoconnect_list.get_item_text(selected_item)].enabled = true
	autoconnect_list.set_item_custom_fg_color(selected_item, Color(1.0, 1.0, 1.0, 1.0))
	autoconnect_list.set_item_tooltip(selected_item, "enabled")
	MavlinkSettings.auto_connect_list_changed.emit(false)
			
func _on_autoconnect_disable_pressed():
	if !autoconnect_list.is_anything_selected():
		Notification.notify(" Select AutoConnect item ", Notification.NOTICE_TYPE.WARNING)
		return
	
	var selected_item:int = autoconnect_list.get_selected_items()[0]
	MavlinkSettings.AutoConnectList[autoconnect_list.get_item_text(selected_item)].enabled = false
	autoconnect_list.set_item_custom_fg_color(selected_item, Color(1.0, 1.0, 1.0, 0.2))
	autoconnect_list.set_item_tooltip(selected_item, "disabled")
	MavlinkSettings.auto_connect_list_changed.emit(true)
