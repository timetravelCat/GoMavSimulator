extends Node

# console settings
var open_console_when_connected:bool
var close_console_when_disconnected:bool
signal open_mavlink_shell
signal close_mavlink_shell

# joystick settings
var joystick:bool
var virtual_joystick:bool
signal joystick_enabled(enable:bool)
signal virutal_joystick_enabled(enable:bool)

# mavsdk sysid settings
var system_id:int
signal system_id_changed(sys_id:int)

# mavsdk compid settings
var component_id:int
signal component_id_changed(component_id:int)

# portforward settings
var udp_portforward_enabled:bool
var udp_portforward_port:int
signal udp_portforward_changed(enable:bool, port:int)

# mavlink auto connection settings
var auto_connect_list:PackedStringArray
var auto_connect_list_enabled:PackedByteArray
signal auto_connect_added(connection:String)
signal auto_connect_removed(connection:String)
signal auto_connect_enabled(connection:String)
signal auto_connect_disabled(connection:String)

func _ready():
	# TODO implement save-load
	pass 
