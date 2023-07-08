extends Node3D

@onready var light:DirectionalLight3D = $DirectionalLight3D
@export_range(0.0, 1.0, 0.01) var day_night:float = 0.3:
	set(_day_night):
		day_night = _day_night
		if light:
			light.rotation.x = -deg_to_rad(90.0)*(1.0-day_night)
