extends Node3D

class_name Vehicle

var Setting:SimulatorSettings.VehicleSetting = null : set = _load_vehicle

var model:Node3D = null
var pose

func _load_vehicle(setting:SimulatorSettings.VehicleSetting):
	print("Loading vehicle ...")
	
	# Set Mesh-Releated Settings
	model = VehicleFactory.model[setting.type].instantiate()
	model.name = setting.name
	model.scale = Vector3(setting.scale, setting.scale, setting.scale)
	
	# Set Pose-Related Settings
	match setting.pose_source:
		SimulatorSettings.POSE_SOURCE.MAVLINK:
			pose = GoMAVSDK.new()
			pose.sys_id = setting.sys_id
			match setting.mavlink_pose_source:
				SimulatorSettings.MAVLINK_POSE_SOURCE.ESTIMATION:
					pose.odometry_source = GoMAVSDK.ODOMETRY_ESTIMATION	
				SimulatorSettings.MAVLINK_POSE_SOURCE.GROUND_TRUTH:
					pose.odometry_source = GoMAVSDK.ODOMETRY_GROUND_TRUTH
			pose.connect("pose_subscribed", _on_pose_stamped_subscribed)
			
		SimulatorSettings.POSE_SOURCE.ROS2:
			pose = PoseStampedSubscriber.new()# get_node("PoseStampedSubscriber")
			pose.topic_name = model.name + "/" + setting.ros2_pose_source
			pose.domain_id = setting.domain_id
			# TODO pose.qos_option
			pose.connect("on_data_subscribed", _on_pose_stamped_subscribed)
			pose.initialize() # start subscription
		
		SimulatorSettings.POSE_SOURCE.NONE:
			pose = Node3D.new()
	
	var topic_prefix:String = model.name + "/"
	
	# TODO Set sensors
	
	add_child(model)
	add_child(pose)

# when setting.pose_source == SimulatorSettings.POSE_SOURCE.ROS2:
func _on_pose_stamped_subscribed(location:Vector3, orientation:Quaternion):
	if model != null:
		model.global_transform = Transform3D(Basis(orientation), location)

# wait until succeeded start_odometry_subscription
func _on_timer_timeout():
	if pose == null:
		return

	var pose_mavsdk := pose as GoMAVSDK
	if not pose_mavsdk:
		return
	
	if pose.start_odometry_subscription() == false:
		get_node("Timer").start()
