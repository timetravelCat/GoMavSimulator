class_name Minimap extends TextureRect

@export var height:float = 200.0 # TODO set camera hight depends on the vehicle's hieght
@export_range(0.0, 1.0, 0.01) var ratio:float = 0.5: set = _ratio_initialize 
@export_range(0.0, 1.0, 0.01) var alpha:float = 0.3: set = _alpha_initialize

func _ready():
	subViewport.world_3d = get_parent().get_window().world_3d
	get_window().size_changed.connect(_on_window_resized)
	_initialize_minimap()
	GeneralSettings.district_changed.connect(_initialize_minimap)
	
func _initialize_minimap():
	_ratio_initialize(ratio)
	_alpha_initialize(alpha)

#func _on_gui_input(event):
#	TODO implement zoom in / out
#	pass # Replace with function body.

func _on_window_resized():
	_initialize_minimap()

func _ratio_initialize(_ratio):
	if not camera or not subViewport:
		return
	
	ratio = _ratio
	var district_size = GeneralSettings.district_AABB.size
	camera.size = district_size.z/2.0
	camera.global_position = GeneralSettings.current_district.global_position \
							+ GeneralSettings.district_AABB.get_center() + \
							Vector3(0.0, height, 0.0)
	var _aspect_ratio = district_size.x / district_size.z
	var _height_size:float = ratio*get_window().size.y
	@warning_ignore("narrowing_conversion")
	subViewport.size = Vector2i(_height_size/_aspect_ratio, _height_size)
	size = subViewport.size

func _alpha_initialize(_alpha):
	alpha = _alpha
	material.set_shader_parameter("alpha", _alpha)

@onready var camera:Camera3D = $SubViewport/Camera3D
@onready var subViewport:SubViewport = $SubViewport
