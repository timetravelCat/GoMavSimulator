extends TextureRect

@onready var camera:Camera3D = $SubViewport/Camera3D
@onready var subViewport:SubViewport = $SubViewport
@export var height:float = 20.0
@export_range(0.0, 1.0, 0.01) var ratio:float = 0.5:
	set(_ratio):
		ratio = _ratio
		resize()
	
@export_range(0.0, 1.0, 0.01) var alpha:float = 0.3:
	set(_alpha):
		alpha = _alpha
		material.set_shader_parameter("alpha", _alpha)

var _map_width_ratio:float = 1.0
var _map_height_ratio:float = 1.0

func _ready():
	subViewport.world_3d = get_parent().get_window().world_3d
	var district_volume = GeneralSettings._district_bb - GeneralSettings._district_aa
	camera.size = maxf(district_volume.x, district_volume.z)/2.0
	camera.global_position = Vector3(0.0, district_volume.y + height,0.0)
	
	var _map_ratio = district_volume.z / district_volume.x
	if _map_ratio > 1.0: # hight is longer than width
		_map_width_ratio = 1.0/_map_ratio
	else: # width is longer then height
		_map_height_ratio = _map_ratio
	
	get_window().size_changed.connect(resize)
	resize()

#func _on_gui_input(event):
#	# TODO implement zoom in / out
#	pass # Replace with function body.

func resize():
	var y_size:float = ratio*get_window().size.y
	@warning_ignore("narrowing_conversion")
	subViewport.size = Vector2i(_map_width_ratio*y_size, _map_height_ratio*y_size)
	size = subViewport.size
