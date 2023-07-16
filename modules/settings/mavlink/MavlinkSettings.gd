extends Node

@export var default_settings:Dictionary = {
	"open_on_connected" : true,
	"close_on_disconnected" : true,
	"system_id": 245,
	"component_id": 190,
	"connection_list": 
		{
			"udp://:14550" : false, 
			"serial://COM3:57600" : true
		},
}
@export var save_path:String

@export_category("Console")
@export var open_on_connected:bool
@export var close_on_disconnected:bool
func open_mavlink_shell():
	_open_mavlink_shell()
func close_mavlink_shell():
	_close_mavlink_shell()

@export_category("MAVSDK")
@export var system_id:int = GoMAVSDKServer.get_system_id(): set = _change_system_id
@export var component_id:int = GoMAVSDKServer.get_component_id(): set = _change_component_id
@export var connection_list:Dictionary
func add_or_enable_connection(address:String, enable:bool):
	_add_or_enable_connection(address, enable)
func remove_connection(address:String):
	_remove_connection(address)

# Not implemented joystick feature yet.
#@export_category("JoyStick")
#@export var joystick:bool
#@export var virtual_joystick:bool

func reset():
	DefaultSettingMethods.reset_default_property(self,default_settings)

func _ready():
	DefaultSettingMethods.load_default_property(self,default_settings,save_path)
	
	GoMAVSDKServer.connect("shell_received", _on_shell_received)
	GoMAVSDKServer.connect("system_discovered", _on_system_discovered)
	GoMAVSDKServer.start_discovery() # start mavsdk discovery 

func _exit_tree():
	DefaultSettingMethods.save_default_property(self,default_settings,save_path)

# Console Methods
@onready var console_timer = $ConsoleTimer
@onready var console_container = $ConsoleContainer
@export var console_scene:PackedScene

func _on_console_timer_timeout():
	for window in console_container.get_children():
		if GoMAVSDKServer.is_system_connected(window.name.to_int()):
			window.notify(0)
		else:
			window.notify(2)
			if close_on_disconnected:
				window.hide()
func _open_mavlink_shell():
	for window in console_container.get_children():
		window.show()	
	for sys_id in GoMAVSDKServer.get_discovered():
		_create_new_mavlink_console(sys_id)
func _close_mavlink_shell():
	for window in console_container.get_children():
		window.hide()	
func _create_new_mavlink_console(sys_id:int)->Window:
	if console_container.has_node(str(sys_id)):
		return null
	var window = console_scene.instantiate()
	window.name = str(sys_id)
	window.title = "SYSTEM ID : " + str(sys_id)
	window.connect("text_submitted_with_sysid", GoMAVSDKServer.send_shell)
	console_container.call_deferred("add_child", window)
	return window
	
# MAVSDK
@onready var autoconnect_timer = $AutoconnectTimer
func _change_system_id(sys_id:int):
	system_id = sys_id
	GoMAVSDKServer.set_system_id(sys_id)
func _change_component_id(comp_id:int):
	component_id = comp_id
	GoMAVSDKServer.set_component_id(comp_id)
func _on_autoconnect_timer_timeout(): # try to reconnect until connection_list is all registered to MAVSDK server.
	var restart:bool = false
	for address in connection_list:
		if connection_list[address]:
			if GoMAVSDKServer.add_connection(address) != GoMAVSDKServer.CONNECTION_SUCCESS:
				restart = true
	if restart:
		autoconnect_timer.start()
func _on_shell_received(sys_id:int, msg:String):
	if console_container.has_node(str(sys_id)):
		console_container.get_node(str(sys_id)).append_contents(msg)
func _on_system_discovered(sys_id:int):
	var window = _create_new_mavlink_console(sys_id)
	if !open_on_connected:
		window.hide()
func _restart_server():
	GoMAVSDKServer.initialize(true) 
	GoMAVSDKServer.start_discovery()
	autoconnect_timer.start()
func _add_or_enable_connection(address:String, enable:bool):
	if !connection_list.has(address): # new connection
		connection_list.merge({address:enable})
		if enable:
			autoconnect_timer.start()
	else: # exist connection
		if connection_list[address] != enable:
			connection_list[address] = enable
			if enable:
				autoconnect_timer.start()
			else:
				_restart_server()
func _remove_connection(address:String):
	if !connection_list.has(address):
		return
	var enabled = connection_list[address]
	connection_list.erase(address)
	if enabled:
		_restart_server()
