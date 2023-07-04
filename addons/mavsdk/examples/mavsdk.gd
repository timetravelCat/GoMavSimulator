extends Node

func _on_system_discovered(sys_id):
	get_node("GoMAVSDK").set_sys_id(sys_id)
	GoMAVSDKServer.send_shell(sys_id, "listener vehicle_attitude")
	pass

func _on_shell_received(sys_id, shell):
	print(shell)
	pass	

# Called when the node enters the scene tree for the first time.
func _ready():
	GoMAVSDKServer.add_connection("serial://COM3:57600")
	GoMAVSDKServer.connect("system_discovered", _on_system_discovered)
	GoMAVSDKServer.connect("shell_received", _on_shell_received)
	GoMAVSDKServer.start_discovery()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Reset GoMAVSDKServer after 5s
func _on_timer_timeout():
	# GoMAVSDKServer.initialize(true)
	# print("Initialized")
	# GoMAVSDKServer.add_connection("serial://COM3:57600")
	pass

# Reconnecting GoMAVSDKServer after 10s
func _on_timer_2_timeout():
	# GoMAVSDKServer.add_connection("serial://COM3:57600")
	# GoMAVSDKServer.start_discovery()
	pass

