extends GlobalWorld

func _get_world_environment()->WorldEnvironment:
	return _world_environment
func _get_light()->DirectionalLight3D:
	return _light
func _set_day_night(time:float):
	_day_night = time

@onready var _light:DirectionalLight3D = $DirectionalLight3D
@onready var _world_environment:WorldEnvironment = $WorldEnvironment
@export_range(0.0, 1.0, 0.01) var _day_night:float = 0.3:
	set(day_night):
		_day_night = day_night
		if _light:
			_light.rotation.x = -deg_to_rad(90.0)*(1.0-day_night)
