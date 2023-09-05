class_name PanoramaDepth extends Sensor

@export var property_saved_list:Dictionary = {
	"position":Vector3(0.0, 0.0, 0.0),
	"quaternion":Quaternion(0.0, 0.0, 0.0, 1.0),
	"frame_id":"/map",
	"hz":10.0,
	"enable":true,
	"resolution":160,
	"left":true,
	"front":true,
	"right":true,
	"back":true,
	"top":false,
	"bottom":false,
}
	
# export viewports
@export var window:Window
@export var viewport_left:SubViewport
@export var viewport_front:SubViewport
@export var viewport_right:SubViewport
@export var viewport_back:SubViewport
@export var viewport_top:SubViewport
@export var viewport_bottom:SubViewport

# enable/disable 
@export var left:bool: set=set_left
@export var front:bool: set=set_front
@export var right:bool: set=set_right
@export var back:bool: set=set_back
@export var top:bool: set=set_top
@export var bottom:bool: set=set_bottom

@export var resolution:int: set = set_resolution

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	set_resolution(resolution)
	set_left(left)
	set_front(front)
	set_right(right)
	set_back(back)
	set_top(top)
	set_bottom(bottom)
	_on_sensor_renamed(vehicle.name, name)
	
	# initialize rendering devices for decoding depth textures (by gpu)
	renderingDevice = RenderingServer.create_local_rendering_device();
	shader_file = load("res://modules/sensor/PanoramaDepth/ComputeDepth.glsl")
	shader_spirv = shader_file.get_spirv()
	shader = renderingDevice.shader_create_from_spirv(shader_spirv)
	
func _on_sensor_enabled(_enable):
	if not window:
		return
	if _enable:
		window.show()
	else:
		window.hide()

func _on_global_window_close_requested():
	enable = false

@warning_ignore("unused_parameter")
func _on_sensor_renamed(vehicle_name, sensor_name):
	window.title = publisher.topic_name

var renderingDevice:RenderingDevice;
var shader_file;
var shader_spirv;
var shader;

func _on_timer_timeout():
	var depth_image = window.get_texture().get_image() 
	depth_image.convert(Image.FORMAT_RGBA8)	
	var depth_image_bytes = depth_image.get_data()
	
	var buffer:RID = renderingDevice.storage_buffer_create(depth_image_bytes.size(), depth_image_bytes)	
	# At this time of writing, (23.07.11) renderingDevice.buffer_update() not working. 
	# As a result, manually create & delte gpu memory is required on every callback.
	# Create a uniform to assign the buffer to the rendering device
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0 # this needs to match the "binding" in our shader file
	uniform.add_id(buffer)
	var uniform_set := renderingDevice.uniform_set_create([uniform], shader, 0) # the last parameter (the 0) needs to match the "set" in our shader file
	# Create a compute pipeline
	var pipeline := renderingDevice.compute_pipeline_create(shader)
	var compute_list := renderingDevice.compute_list_begin()
	renderingDevice.compute_list_bind_compute_pipeline(compute_list, pipeline)
	renderingDevice.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	@warning_ignore("integer_division")
	renderingDevice.compute_list_dispatch(compute_list, depth_image_bytes.size()/4 + 1, 1, 1)
	renderingDevice.compute_list_end()
	# Submit to GPU and wait for sync
	renderingDevice.submit()
	renderingDevice.sync()
	
	var output_bytes := renderingDevice.buffer_get_data(buffer)
	var output_image = Image.create_from_data(depth_image.get_width(),depth_image.get_height(), false, Image.FORMAT_RF, output_bytes)
	publisher.image = output_image
	publisher.publish()
	renderingDevice.free_rid(buffer)

func set_resolution(_resolution):
	resolution = _resolution
	if not is_node_ready():
		return
	
	viewport_left.size = Vector2i(_resolution, _resolution)
	viewport_front.size = Vector2i(_resolution, _resolution)
	viewport_right.size = Vector2i(_resolution, _resolution)
	viewport_back.size = Vector2i(_resolution, _resolution)
	viewport_top.size = Vector2i(_resolution, _resolution)
	viewport_bottom.size = Vector2i(_resolution, _resolution)
	resize_window()

func _on_allways_on_top_button_toggled(button_pressed):
	window.always_on_top = button_pressed

func set_left(_left):
	left = _left
	if not is_node_ready():
		return
		
	if _left:
		viewport_left.get_parent().show()
	else:
		viewport_left.get_parent().hide()
	resize_window()

func set_front(_front):
	front = _front
	if not is_node_ready():
		return
		
	if _front:
		viewport_front.get_parent().show()
	else:
		viewport_front.get_parent().hide()
	resize_window()

func set_right(_right):
	right = _right
	if not is_node_ready():
		return
		
	if _right:
		viewport_right.get_parent().show()
	else:
		viewport_right.get_parent().hide()
	resize_window()

func set_back(_back):
	back = _back
	if not is_node_ready():
		return
		
	if _back:
		viewport_back.get_parent().show()
	else:
		viewport_back.get_parent().hide()
	resize_window()
	
func set_top(_top):
	top = _top
	if not is_node_ready():
		return
		
	if _top:
		viewport_top.get_parent().show()
	else:
		viewport_top.get_parent().hide()
	resize_window()
	
func set_bottom(_bottom):
	bottom = _bottom
	if not is_node_ready():
		return
		
	if _bottom:
		viewport_bottom.get_parent().show()
	else:
		viewport_bottom.get_parent().hide()
	resize_window()
	
func resize_window():
	var num_enabled:int = 0
	num_enabled += (1 if left else 0)
	num_enabled += (1 if front else 0)
	num_enabled += (1 if right else 0)
	num_enabled += (1 if back else 0)
	num_enabled += (1 if top else 0)
	num_enabled += (1 if bottom else 0)
	window.size = Vector2i(num_enabled*resolution, resolution)

@onready var allwaysOnTopButton = $GlobalWindow/AllwaysOnTopButton

func _on_grid_container_gui_input(event):
	if event is InputEventMouseButton:
		var mouseEvent = event as InputEventMouseButton
		if mouseEvent.pressed and mouseEvent.button_index == MOUSE_BUTTON_RIGHT:
			allwaysOnTopButton.visible = !allwaysOnTopButton.visible
