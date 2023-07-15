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
	return GoMAVSDK.ODOMETRY_GROUND_TRUTH

func _on_go_mavsdk_pose_subscribed(position, orientation):
	pose_update.emit(position, orientation)
