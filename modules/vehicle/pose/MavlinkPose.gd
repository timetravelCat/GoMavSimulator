class_name MavlinkPose extends VehiclePose

@export var goMAVSDK:GoMAVSDK

func _enable(enable:bool):
	goMAVSDK.sys_enable = enable
func _set_sys_id(sys_id:int):
	goMAVSDK.sys_id = sys_id
func _set_odometry_source(odometry_source:GoMAVSDK.OdometrySource):
	goMAVSDK.odometry_source = odometry_source

func _on_go_mavsdk_pose_subscribed(position, orientation):
	pose_update.emit(position, orientation)
