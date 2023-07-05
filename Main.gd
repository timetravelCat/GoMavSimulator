extends Node3D

@onready var publisher:PoseStampedPublisher = $PoseStampedPublisher

func _ready():
	# Currently, for testing
	var vehicle:Vehicle = Vehicle.new()
	vehicle.name = "vehicle"
	vehicle.enable = true
	vehicle.pose_type = Vehicle.POSE_TYPE.ROS2
	vehicle.pose.name = "pose"
	var vehicle_pose_subscriber = vehicle.pose as PoseStampedSubscriber
	print(vehicle.pose.topic_name)
	add_child(vehicle) 

var t = 0.0
func _process(delta):
	t += delta
	var z:float = cos(t)
	publisher.publish(Vector3(0,0,z), Quaternion.IDENTITY)
