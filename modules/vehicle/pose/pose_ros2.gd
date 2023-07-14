#extends PoseStampedSubscriber
#
#func _enter_tree():
#	get_parent().connect("renamed", _on_renamed)
#	_on_renamed()
#
#func _on_renamed():
#	if get_parent() and !get_parent().name.is_empty() and !name.is_empty():
#		topic_name = get_parent().name + "/" + name	
#
#func _on_on_data_subscribed(position, orientation):
#	if get_parent():
#		get_parent().global_transform = Transform3D(Basis(orientation), position)
#
## implement save_load
