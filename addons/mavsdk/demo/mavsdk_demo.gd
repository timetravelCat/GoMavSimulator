extends Control

# !WARNING!
# Do not directly inherit GDExtension nodes, at the moment of writing(2023.07.19), has bug on GDExtension.
# Do not create @onready, static obejct includes GDExtension Nodes either. Use @export or get_node instead.
@export var goMAVSDK:GoMAVSDK
@onready var syslabel:Label = $HFlowContainer/Label
@onready var poseLabel:Label = $HFlowContainer/Label2
func on_system_discovered(sys_id):
	syslabel.text = syslabel.text + str(sys_id) + "\n"
	goMAVSDK.sys_id = sys_id
	# You see GoMAVSDK Search Help Section to know more supported apis.
	
func _ready():
	GoMAVSDKServer.system_discovered.connect(on_system_discovered)

# Poses are automatically subscribed, 
# (at least ur system emit proper mavlink messages, HIL_STATE_QUATERNION for GROUND_TRUTH MODE, LOCAL_POSITION_NED & ATTITUDE_QUATERNON for ESTIMATION MODE)
func _on_go_mavsdk_pose_subscribed(position, orientation):
	poseLabel.text = str(position)
