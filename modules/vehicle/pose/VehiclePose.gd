# Base class for vehicle pose
class_name VehiclePose extends Node

enum POSE_TYPE {MAVLINK, ROS2, USER} 

@export var type:POSE_TYPE

static var POSE_TYPE_STRING:PackedStringArray = [
	"MAVLINK",
	"ROS2",
	"USER",
]

static func Create(vehicle:Vehicle, pose_type:POSE_TYPE)->VehiclePose:
	var pose:VehiclePose 
	match pose_type:
		POSE_TYPE.MAVLINK:
			pose = load("res://modules/vehicle/pose/MavlinkPose.tscn").instantiate()
		POSE_TYPE.ROS2:
			pose = load("res://modules/vehicle/pose/Ros2Pose.tscn").instantiate()
		POSE_TYPE.USER:
			pose = load("res://modules/vehicle/pose/UserPose.tscn").instantiate()
	pose.name = "pose"
	
	if vehicle.pose:
		pose._set_enable(vehicle.pose._get_enable())
		pose._set_sys_id(vehicle.pose._get_sys_id())
		pose._set_odometry_source(vehicle.pose._get_odometry_source())
		pose._set_domain_id(vehicle.pose._get_domain_id())
		vehicle.remove_child(vehicle.pose)
		vehicle.pose.free()		
	
	vehicle.add_child(pose)
	vehicle.pose = pose
	return pose

signal pose_update(position, quaternion)
signal armed_updated(armed)
signal flight_mode_updated(flight_mode)

@warning_ignore("unused_parameter")
func _set_enable(enable:bool):
	pass
func _get_enable()->bool:
	return true
@warning_ignore("unused_parameter")
func _set_sys_id(sys_id:int):
	pass
func _get_sys_id()->int:
	return 1
@warning_ignore("unused_parameter")
func _set_odometry_source(odometry_source:GoMAVSDK.OdometrySource):
	pass
func _get_odometry_source()->GoMAVSDK.OdometrySource:
	return GoMAVSDK.ODOMETRY_GROUND_TRUTH
@warning_ignore("unused_parameter")
func _set_domain_id(domain_id:int):
	pass
func _get_domain_id()->int:
	return 0

func _enter_tree():
	pose_update.connect(_on_pose_updated)

func _on_pose_updated(position, quaternion):
	if not get_parent():
		return
	var vehicle = get_parent() as Node3D
	vehicle.global_transform = Transform3D(Basis(quaternion), position)
