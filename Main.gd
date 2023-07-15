extends Node3D

# @onready var publisher:PoseStampedPublisher = $PoseStampedPublisher
var vehicle_scene = preload("res://modules/vehicle/Vehicle.tscn")

func _ready():
	# Currently, for testing
#	var vehicle:Vehicle = vehicle_scene.instantiate()
#	vehicle.name = "vehicle"
#	vehicle.enable = true
#	vehicle.model_type = Vehicle.MODEL_TYPE.MULTICOPTER
#	vehicle.pose_type = Vehicle.POSE_TYPE.ROS2
#	vehicle.pose.name = "pose"
#	var vehicle_pose_subscriber = vehicle.pose as PoseStampedSubscriber
#	print(vehicle.pose.topic_name)
#	add_child(vehicle) 	
#	remove_child(vehicle)
#	# vehicle.free()
#
#	var vehicle2 = Vehicle.new()
#	vehicle2.name = "vehicle"
#	vehicle2.enable = true
#	vehicle2.model_type = Vehicle.MODEL_TYPE.MULTICOPTER
#	vehicle2.pose_type = Vehicle.POSE_TYPE.ROS2
#	vehicle2.pose.name = "pose"
#	# vehicle.free()
#	add_child(vehicle2) 	
	
	pass
var t = 0.0
func _process(delta):
	t += delta
	var z:float = cos(t)
	# publisher.publish(Vector3(0,0,z), Quaternion.IDENTITY)



