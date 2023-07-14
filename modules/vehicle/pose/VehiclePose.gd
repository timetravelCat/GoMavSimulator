# Base class for vehicle pose
class_name VehiclePose extends Node

enum POSE_TYPE {MAVLINK, ROS2, USER} 

static var POSE_TYPE_STRING:PackedStringArray = [
	"MAVLINK",
	"ROS2",
	"USER",
]

static func Create(sensor_type:POSE_TYPE)->Node3D:
	match sensor_type:
		POSE_TYPE.MAVLINK:
			return load("res://modules/vehicle/pose/MavlinkPose.tscn").instantiate()
		POSE_TYPE.ROS2:
			return load("res://modules/vehicle/pose/Ros2Pose.tscn").instantiate()
		POSE_TYPE.USER:
			return load("res://modules/vehicle/pose/PoseUser.tscn").instantiate()
	return null

signal pose_update(position, quaternion)

func _enable(enable:bool):
	pass
func _set_sys_id(sys_id:int):
	pass
func _set_odometry_source(odometry_source:GoMAVSDK.OdometrySource):
	pass
func _set_domain_id(domain_id:int):
	pass

func _enter_tree():
	pose_update.connect(_on_pose_updated)
	
func _on_pose_updated(position, quaternion):
	if not get_parent():
		return
	var vehicle = get_parent() as Node3D
	vehicle.global_transform = Transform3D(Basis(quaternion), position)
