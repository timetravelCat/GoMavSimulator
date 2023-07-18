class_name MavlinkPose extends VehiclePose

@export var goMAVSDK:GoMAVSDK

func _set_enable(enable:bool):
	goMAVSDK.sys_enable = enable
func _set_sys_id(sys_id:int):
	goMAVSDK.sys_id = sys_id
func _set_odometry_source(odometry_source:GoMAVSDK.OdometrySource):
	goMAVSDK.odometry_source = odometry_source

func _get_enable()->bool:
	return goMAVSDK.sys_enable
func _get_sys_id()->int:
	return goMAVSDK.sys_id
func _get_odometry_source()->GoMAVSDK.OdometrySource:
	return goMAVSDK.odometry_source
func _on_go_mavsdk_pose_subscribed(position, orientation):
	pose_update.emit(position, orientation)

func _on_go_mavsdk_response_action(result):
	var action_result = result as GoMAVSDKServer.ActionResult
	if action_result != GoMAVSDKServer.ACTION_SUCCESS:
		Notification.notify(" ARM/DISARM Request Failed ", Notification.NOTICE_TYPE.ALERT)
func _on_go_mavsdk_response_manual_control(result):
	var manual_control_result = result as GoMAVSDKServer.ManualControlResult
	if manual_control_result != GoMAVSDKServer.MANUAL_CONTROL_SUCCESS:
		Notification.notify(" MODE Request Failed ", Notification.NOTICE_TYPE.ALERT)

# input handling
func _input(event):
	if not goMAVSDK.sys_enable:
		return
	if not MavlinkSettings.enable_virtual_joystick and not MavlinkSettings.enable_joystick:
		return
	
	# TODO only "selected" vehicle is => set_process_input(true/false) of node
	if event.is_action_pressed("arm"):
		goMAVSDK.request_arm()
	if event.is_action_pressed("disarm"):
		goMAVSDK.request_disarm()
	if event.is_action_pressed("position_mode"):
		goMAVSDK.request_manual_control(GoMAVSDKServer.MANUAL_CONTROL_POSITION)
	if event.is_action_pressed("altitude_mode"):
		goMAVSDK.request_manual_control(GoMAVSDKServer.MANUAL_CONTROL_ALTITUDE)
 
@onready var timer:Timer = $ManualControlTimer
func _on_manual_control_timer_timeout():
	if not goMAVSDK.sys_enable:
		return
	if not MavlinkSettings.enable_virtual_joystick and not MavlinkSettings.enable_joystick:
		return
	semaphore.post()

func _ready():
	exit_thread = false
	semaphore = Semaphore.new()
	thread = Thread.new()
	thread.start(_send_manual_control)
func _exit_tree():
	exit_thread = true
	semaphore.post()
	thread.wait_to_finish()
	
func _send_manual_control():
	while true:
		semaphore.wait() 
		if exit_thread:
			break
		var r = Input.get_axis("rudder_down", "rudder_up")
		var z = Input.get_axis("throttle_down", "throttle_up")
		var x = Input.get_axis("elevator_down", "elevator_up")
		var y = Input.get_axis("aileron_down", "aileron_up")
		z = (z + 1.0)/2.0 # throttle [-1, 1] to [0, 1]
		goMAVSDK.send_manual_control(x, y, z, r)

var exit_thread:bool
var semaphore:Semaphore
var thread:Thread
