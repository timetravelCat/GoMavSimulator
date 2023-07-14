class_name GlobalWorld extends Node3D

func _get_world_environment()->WorldEnvironment:
	return null
func _get_light()->DirectionalLight3D:
	return null
@warning_ignore("unused_parameter")
func _set_day_night(time:float):
	return
