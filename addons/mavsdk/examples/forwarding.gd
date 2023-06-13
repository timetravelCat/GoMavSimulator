extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	# Currently has bug when exiting.
	GoMAVSDKServer.add_connection("udp://127.0.0.1:14540", GoMAVSDKServer.FORWARD_ON)
	GoMAVSDKServer.add_connection("serial://COM3:57600", GoMAVSDKServer.FORWARD_ON)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

