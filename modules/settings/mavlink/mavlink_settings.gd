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
const DEFAULT_SYS_ID:int = 245
var system_id:int
signal system_id_changed(sys_id:int)

# mavsdk compid settings
const DEFAULT_COMP_ID:int = 190
var component_id:int
signal component_id_changed(component_id:int)

# portforward settings
const DEFAULT_UDP_PORTFORWARD_PORT = 14446
var udp_portforward_enabled:bool
var udp_portforward_port:int
signal udp_portforward_changed(enable:bool, port:int)

# mavlink auto connection settings
class AutoConnect:
	var index:int # ItemList index
	var enabled:bool
	
var AutoConnectList:Dictionary # contains [address(String), AutoConnect]

const DEFAULT_AUTOCONNECT_LIST:Dictionary = {
	"udp://:14550" : true,		 	# index = 0, enabled = true
	"serial://COM3:57600" : false 	# index = 1, enabled = false
}

func _ready():
	# TODO implement save-load
	pass 
