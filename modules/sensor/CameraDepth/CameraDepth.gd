class_name CameraDepth extends Sensor

@export var property_saved_list:Dictionary = {
	"position":Vector3(0.0, 0.0, 0.0),
	"quaternion":Quaternion(0.0, 0.0, 0.0, 1.0),
	"frame_id":"/map",
	"hz":10.0,
	"enable":true,
	"resolution":Vector2i(320,180),
	"fov":75.0,
}

@onready var subViewport:SubViewport = $SubViewport
@onready var camera3D:Camera3D = $SubViewport/Camera3D
@onready var window:Window = $Window
@export var resolution:Vector2i = Vector2i(320,180): set = set_resolution
@export var fov:float = 75.0: set = set_fov
@export var cameraInfoPublisher:CameraInfoPublisher

func _ready():
	super._ready()
	set_resolution(resolution)
	set_fov(fov)
	_on_sensor_renamed(vehicle.name, name)
		
	# initialize rendering devices for decoding depth textures (by gpu)
	renderingDevice = RenderingServer.create_local_rendering_device();
	shader_file = load("res://modules/sensor/CameraDepth/ComputeDepth.glsl")
	shader_spirv = shader_file.get_spirv()
	shader = renderingDevice.shader_create_from_spirv(shader_spirv)

@warning_ignore("unused_parameter")
func _on_sensor_renamed(vehicle_name:String, sensor_name:String):
	cameraInfoPublisher.topic_name = vehicle_name + "/" + sensor_name + "_info"
	if window:
		window.title = publisher.topic_name

#@export var decode_cpu:bool = false
var renderingDevice:RenderingDevice;
var shader_file;
var shader_spirv;
var shader;

func _on_timeout():
	# TODO implement cpu decoding from depth texture 
	var depth_image = subViewport.get_texture().get_image() 
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

func _on_sensor_enabled(_enable:bool):
	if not window:
		return
	if _enable:
		window.show()
	else:
		window.hide()

func _on_window_close_requested():
	enable = false

func set_resolution(_resolution):
	resolution = _resolution
	if subViewport:
		subViewport.size = _resolution
	if window:
		window.size = resolution
	
func set_fov(_fov):
	if fov:
		fov = _fov
	if camera3D:
		camera3D.fov = fov

func _on_always_on_top_button_toggled(button_pressed):
	window.always_on_top = button_pressed

func _on_sub_viewport_size_changed():
	cameraInfoPublisher.publish()

func _on_timer_timeout():
	cameraInfoPublisher.publish()

func _on_domain_id_changed(domain_id):
	cameraInfoPublisher.domain_id = domain_id
