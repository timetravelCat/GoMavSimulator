extends VehiclePose

@export var poseSubscriber:PoseStampedSubscriber

var stop:bool = false

func _set_enable(enable:bool):
	stop = !enable
func _set_domain_id(domain_id:int):
	poseSubscriber.domain_id = domain_id

func _get_enable()->bool:
	return !stop
func _get_domain_id()->int:
	return poseSubscriber.domain_id

func _enter_tree():
	super._enter_tree()
	get_parent().connect("renamed", _on_renamed)

func _ready():
	renamed.emit()

func _on_renamed():
	if get_parent() and !get_parent().name.is_empty() and !name.is_empty():
		poseSubscriber.topic_name = get_parent().name + "/" + name	

func _on_pose_stamped_subscriber_on_data_subscribed(position, orientation):
	if stop:
		armed_updated.emit(false)
		return
	pose_update.emit(position, orientation)
	armed_updated.emit(true)
