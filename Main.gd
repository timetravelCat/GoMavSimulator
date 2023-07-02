extends Node3D

@onready var publisher:PoseStampedPublisher = $PoseStampedPublisher

func _ready():
	# Currently, for testing
	
	# TEST case 1 (by mavlink message)
	var setting:SimulatorSettings.VehicleSetting = SimulatorSettings.VehicleSetting.new()
	setting.type = 0
	
	# TEST case 2 (by ros2 pose topic)
	setting.pose_source = SimulatorSettings.POSE_SOURCE.ROS2
	setting.name = "model"
	setting.ros2_pose_source = "pose"
	setting.domain_id = 0
	
	add_child(VehicleFactory.Create(setting)) 

var t = 0.0
func _process(delta):
	t += delta
	var z:float = cos(t)
	publisher.publish(Vector3(0,0,z), Quaternion.IDENTITY)
