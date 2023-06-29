extends Node

# Vehicle configuritions
enum VEHICLE_TYPE {MULTICOPTER, ROVER}
enum POSE_SOURCE {MAVLINK, ROS2, NONE}
enum MAVLINK_POSE_SOURCE {GROUND_TRUTH, ESTIMATION}

# Default advanced vehicle setting defaults
const VEHICLE_DEFAULT_SCALE:float=10.0
const MAVLINK_POSE_SOURCE_DEFAULT=SimulatorSettings.MAVLINK_POSE_SOURCE.GROUND_TRUTH
const VEHILE_SYSID_DEFAULT:int=0
const ROS2_POSE_TOPIC_DEFAULT:String="pose"

# Default advanced sensor settings defaults
const RGB_CAMERA_DEFAULT_RESOLUTION:Vector2i = Vector2i(640, 360)
const DEPTH_CAMERA_DEFUALT_RESOLUTION:Vector2i = Vector2i(360, 180)
const LIDAR_DEFAULT_VERTICAL_FOV:float = 0.0
const LIDAR_DEFAULT_VERTICAL_RESOLUTION:float = 0.0 
const LIDAR_DEFAULT_HORIZONTAL_RESOLUTION:float = deg_to_rad(5.0)

class Vehicle:
	var item_id:int # itemlist control id
	var enable:bool
	var name:String
	var type:VEHICLE_TYPE
	var scale:float
	var pose_source:POSE_SOURCE
	var domain_id:int
	# advanced setting
	var mavlink_pose_source:MAVLINK_POSE_SOURCE
	var sys_id:int # mavlink system id
	var ros2_pose_source:String # name of PoseStamped topic.
	var sensors:Dictionary # ["name", Sensor]

var VehicleList:Dictionary # Array of dictionary ["name", Vehicle]

# Sensor configurations
enum SENSOR_TYPE {RGB_CAMERA, DEPTH_CAMERA, RANGE, LIDAR}

# Sensor dictionary structure
class Sensor:
	var item_id:int # itemlist control id
	var enable:bool
	var name:String # name of ros2 published topic
	var type:SENSOR_TYPE
	var location:Vector3
	var rotation:Basis
	var hz:float # publish hz
	# advanced setting
	var resoultion:Vector2i # CAMERA TYPE RESOLUTION
	var vertical_fov:float # LIDAR in radian, horizontal resoultion is 360 deg.
	var vertical_resolution:float # LIDAR vertical resolution in radian
	var horizontal_resolution:float # LIDAR horizontal resolution in radian
