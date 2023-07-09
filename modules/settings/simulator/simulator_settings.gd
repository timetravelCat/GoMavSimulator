extends Node

# vehicle defaults 
const def_vehicle_name:String = "vehicle"
const def_model_type:Vehicle.MODEL_TYPE = Vehicle.MODEL_TYPE.MULTICOPTER
const def_domain_id:int = 0
const def_ros2_pose_subscriber_topic_name:String = "pose"
const def_sys_id:int = 1
const def_vehicle_scale:float = 1.0
const def_vehicle_scaler:float = 10.0
const def_pose_type:Vehicle.POSE_TYPE = Vehicle.POSE_TYPE.ROS2 # Temporary
const def_odometry_source:GoMAVSDK.OdometrySource = GoMAVSDK.OdometrySource.ODOMETRY_GROUND_TRUTH
const def_frame_id:String = "/map"

# sensor defaults
const def_range_distance:float = 100.0
const def_lidar_distance:float = 100.0
const def_lidar_resolution:Vector2i = Vector2(72,1)
const def_lidar_vertical_fov:float = 0.0
const def_rgb_camera_resolution:Vector2i = Vector2(640, 320)
const def_rgb_camera_fov:float = 75.0
const def_rgb_camera_compressed:bool = false

var VehicleContainer:Node
var VehicleLoader:PackedScene = preload("res://modules/vehicle/Vehicle.tscn")

func _init():
	VehicleContainer = Node.new()
	VehicleContainer.name = "VehicleContainer"
	add_child(VehicleContainer)

func get_vehicle(vehicle_name:String)->Vehicle:
	return VehicleContainer.find_child(vehicle_name, false, false)

func add_vehicle(
					vehicle_name:String = def_vehicle_name, \
					model_type:Vehicle.MODEL_TYPE = def_model_type, \
					domain_id:int = def_domain_id, \
					pose_type:Vehicle.POSE_TYPE = def_pose_type, \
					vehicle_scale:float = def_vehicle_scale, \
					odometry_source:GoMAVSDK.OdometrySource = def_odometry_source, \
					sys_id:int = def_sys_id, \
					ros2_pose_source:String = def_ros2_pose_subscriber_topic_name)->bool:
	if VehicleContainer.find_child(vehicle_name, false, false):
		Notification.notify("Same vehicle name found : " + vehicle_name, Notification.NOTICE_TYPE.ALERT)
		return false
	
	var vehicle:Vehicle = VehicleLoader.instantiate() as Vehicle
	vehicle.name = vehicle_name
	vehicle.model_type = model_type
	vehicle.domain_id = domain_id
	vehicle.pose_type = pose_type
	vehicle.model.scale = Vector3(vehicle_scale, vehicle_scale, vehicle_scale)
	
	var pose = vehicle.pose as GoMAVSDK
	if pose:
		pose.odometry_source = odometry_source
		pose.sys_id = sys_id
	
	pose = vehicle.pose as PoseStampedSubscriber
	if pose:
		pose.name = ros2_pose_source
		
	VehicleContainer.add_child(vehicle)
	return true

func remove_vehicle(vehicle_name:String):
	var vehicle = get_vehicle(vehicle_name)
	if vehicle:
		VehicleContainer.remove_child(vehicle)
		vehicle.free()
