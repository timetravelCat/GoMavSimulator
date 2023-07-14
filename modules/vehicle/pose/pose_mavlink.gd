#extends GoMAVSDK
#
#func _on_pose_subscribed(_position, _orientation):
#	if get_parent():
#		get_parent().global_transform = Transform3D(Basis(_orientation), _position)
#
## implement save-load
