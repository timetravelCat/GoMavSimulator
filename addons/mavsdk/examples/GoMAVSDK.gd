extends GoMAVSDK

var once_connected
# Called when the node enters the scene tree for the first time.
func _ready():
	once_connected = false
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_system_connected() && !once_connected:
		once_connected = true
		print("conneted to sysid = ", sys_id)

		send_shell("listener vehicle_angular_acceleration")
		print(get_param("MAV_SYS_ID")) 
		print(get_param("MAV_SYSS_ID")) # Non-exist parameter case
		add_mavlink_subscription(74) # 74 : VFR_HUD
	pass

func _on_shell_received(shell):
	print(shell)
	pass 

func _on_mavlink_received(message):
	# TODO Requires parsing library for mavlink messages
	# print("VFR_HUD RECEIVED")
	pass 
