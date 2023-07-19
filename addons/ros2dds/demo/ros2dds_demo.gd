extends Control

# !WARNING!
# Do not directly inherit GDExtension nodes, at the moment of writing(2023.07.19), has bug on GDExtension.
# Do not create @onready, static obejct includes GDExtension Nodes either. Use @export or get_node instead.
@export var poseStampedPublisher:PoseStampedPublisher
@export var imagePublisher:ImagePublisher
@export var markerPublisher:MarkerPublisher
# See PoseStampedSubscriber Signal.
@onready var poseSubscriberLabel:Label = $HFlowContainer/PoseSubscriberLabel
func _on_pose_stamped_subscriber_on_data_subscribed(position, orientation):
	poseSubscriberLabel.text = str(position)
func _on_pose_button_pressed():
	poseStampedPublisher.publish(Vector3(0.0, 1.0, 2.0), Quaternion())
func _on_image_button_pressed():
	imagePublisher.publish() # publish current viewport's image, if not any variable passed.
func _on_marker_button_pressed():
	markerPublisher.publish(Vector3(0.0, 2.0, 1.0), Quaternion()) 
	# Marker publisher has more advanced features, 
	# If you set surface property (by node3d, all meshes of childs of the node will be published, requires a lot of cpu, but not a realtime feature)
	# Godot 3D coordinates are interpreted as EUS (front-up-right). Try check "EUS to ENU" property 
