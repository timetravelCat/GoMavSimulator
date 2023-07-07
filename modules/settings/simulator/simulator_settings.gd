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

var VehicleContainer:Node
var VehicleLoader:PackedScene = preload("res://modules/vehicle/Vehicle.tscn")

func _init():
	VehicleContainer = Node.new()
	VehicleContainer.name = "VehicleContainer"
	add_child(VehicleContainer)

func get_vehicle(vehicle_name:String)->Vehicle:
	return VehicleContainer.find_child(vehicle_name, false, false)

func add_vehicle(
					vehicle_name:String, \
					model_type:Vehicle.MODEL_TYPE = Vehicle.MODEL_TYPE.MULTICOPTER, \
					domain_id:int = 0, \
					pose_type:Vehicle.POSE_TYPE = Vehicle.POSE_TYPE.MAVLINK, \
					vehicle_scale:float = 1.0, \
					odometry_source:GoMAVSDK.OdometrySource = GoMAVSDK.OdometrySource.ODOMETRY_GROUND_TRUTH, \
					sys_id:int = 1, \
					ros2_pose_source:String = "pose")->bool:
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

## Sensor configurations
#enum SENSOR_TYPE {RGB_CAMERA, DEPTH_CAMERA, RANGE, LIDAR}
#
## Sensor dictionary structure
#class Sensor:
#	var item_id:int # itemlist control id
#	var enable:bool
#	var name:String # name of ros2 published topic
#	var type:SENSOR_TYPE
#	var location:Vector3
#	var rotation:Basis
#	var hz:float # publish hz
#	# advanced setting
#	var resoultion:Vector2i # CAMERA TYPE RESOLUTION
#	var vertical_fov:float # LIDAR in radian, horizontal resoultion is 360 deg.
#	var vertical_resolution:float # LIDAR vertical resolution in radian
#	var horizontal_resolution:float # LIDAR horizontal resolution in radian
#	var range_distance:float
