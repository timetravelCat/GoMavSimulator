extends Node

# console settings
var open_console_when_connected:bool = true
var close_console_when_disconnected:bool = true
signal open_mavlink_shell
signal close_mavlink_shell
var console_timer:Timer
var console:PackedScene = preload("res://modules/console/Console.tscn")

# joystick settings
var joystick:bool
var virtual_joystick:bool
signal joystick_enabled(enable:bool)
signal virutal_joystick_enabled(enable:bool)

# mavsdk sysid settings
const DEFAULT_SYS_ID:int = 245
var system_id:int
signal system_id_changed(sys_id:int)

# mavsdk compid settings
const DEFAULT_COMP_ID:int = 190
var component_id:int
signal component_id_changed(component_id:int)

# mavlink auto connection settings
class AutoConnect:
	var index:int # ItemList index
	var enabled:bool

signal auto_connect_list_changed(reset:bool)
var AutoConnectList:Dictionary # contains [address(String), AutoConnect]
var auto_connect_timer:Timer

const DEFAULT_AUTOCONNECT_LIST:Dictionary = {
	"udp://:14550" : false,		 	# index = 0, enabled = true
	"serial://COM3:57600" : true 	# index = 1, enabled = false
}

func _ready():
	# TODO load saved option
	
	# initialize mavlink console
	console_timer = Timer.new()
	console_timer.name = "console_timer"
	console_timer.wait_time = 5.0
	console_timer.one_shot = false
	console_timer.autostart = true
	console_timer.connect("timeout", _console_timer_timeout)
	add_child(console_timer)
	connect("open_mavlink_shell", show_consoles)
	connect("close_mavlink_shell", hide_consoles)
	GoMAVSDKServer.connect("shell_received", _on_shell_received)
	
	# initialize mavsdk server
	auto_connect_timer = Timer.new()
	auto_connect_timer.name = "auto_connect_timer"
	auto_connect_timer.wait_time = 1.0
	auto_connect_timer.one_shot = false
	auto_connect_timer.autostart = true
	auto_connect_timer.connect("timeout", _on_auto_connect_timer_timeout)
	add_child(auto_connect_timer)
	GoMAVSDKServer.connect("system_discovered", _on_system_discovered)
	GoMAVSDKServer.start_discovery() # start mavsdk discovery 
	start_autoconnect(false)
	connect("auto_connect_list_changed", start_autoconnect)

func _exit_tree():
	GoMAVSDKServer.initialize(true) 

func _console_timer_timeout():
	for child in get_children():
		var window := child as Window
		if window:
			if GoMAVSDKServer.is_system_connected(window.name.to_int()):
				window.notify(0)
			else:
				if close_console_when_disconnected:
					window.hide()
				window.notify(2)

func _on_system_discovered(sys_id:int):
	if !has_node(str(sys_id)):
		var window:Window = console.instantiate()
		window.name = str(sys_id)
		window.title = "SYSTEM ID : " + str(sys_id)
		window.connect("text_submitted_with_sysid", GoMAVSDKServer.send_shell)
		call_deferred("add_child", window)
		if !open_console_when_connected:
			window.hide()

func _on_shell_received(sys_id:int, msg:String):
	if has_node(str(sys_id)):
		get_node(str(sys_id)).append_contents(msg)
		print(msg)

func show_consoles():
	for child in get_children():
		var window := child as Window
		if window:
			window.show()
			
	var discorvered:PackedInt32Array = GoMAVSDKServer.get_discovered()
	for sys_id in discorvered:
		if !has_node(str(sys_id)):
			var window:Window = console.instantiate()
			window.name = str(sys_id)
			window.title = "SYSTEM ID : " + str(sys_id)
			window.connect("text_submitted_with_sysid", GoMAVSDKServer.send_shell)
			call_deferred("add_child", window)

func hide_consoles():
	for child in get_children():
		var window := child as Window
		if window:
			window.hide()

func start_autoconnect(reset:bool):
	if reset: # in case of reset required, initialize server (required for disconnect server)
		GoMAVSDKServer.initialize(true) # This stops all vehicle mavlink subscription's stop
		GoMAVSDKServer.start_discovery()
		get_tree().call_group("VehicleTimer", "start") # TODO find better way
	_on_auto_connect_timer_timeout()

# try to connection until success all connection
func _on_auto_connect_timer_timeout():
	var restart_timer:bool = false
	for key in AutoConnectList:
		var autoConnect:AutoConnect = AutoConnectList[key]
		if autoConnect.enabled:
			if GoMAVSDKServer.add_connection(key) != GoMAVSDKServer.CONNECTION_SUCCESS:
				restart_timer = true
	if restart_timer:
		auto_connect_timer.start()
