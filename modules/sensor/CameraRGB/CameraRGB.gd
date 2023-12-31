class_name CameraRGB extends Sensor

@export var property_saved_list:Dictionary = {
	"position":Vector3(0.0, 0.0, 0.0),
	"quaternion":Quaternion(0.0, 0.0, 0.0, 1.0),
	"frame_id":"/map",
	"hz":10.0,
	"enable":true,
	"compressed":false,
	"resolution":Vector2i(640,360),
	"fov":75.0,
}

@onready var subViewport:SubViewport = $SubViewport
@export var imagePublisher:ImagePublisher
@export var compressedImagePulibsher:CompressedImagePublisher
@export var cameraInfoPublisher:CameraInfoPublisher
@onready var camera3D:Camera3D = $SubViewport/Camera3D
@onready var window:Window = $Window
@onready var infoTimer:Timer = $Timer

@export var compressed:bool = false: set = set_compressed
@export var resolution:Vector2i = Vector2i(640,360): set = set_resolution
@export var fov:float = 75.0: set = set_fov

func _ready():
	super._ready()
	set_compressed(compressed)
	set_resolution(resolution)
	set_fov(fov)
	subViewport.world_3d = get_viewport().world_3d
	on_sensor_renamed(vehicle.name, name)

func on_sensor_renamed(vehicle_name:String, sensor_name:String):
	cameraInfoPublisher.topic_name = vehicle_name + "/" + sensor_name + "_info"
	window.title = publisher.topic_name
	
func _on_timeout():
	publisher.publish()
	
# slow publisher timer for camera info publisher
func _on_timer_timeout():
	cameraInfoPublisher.publish()

func _on_sub_viewport_size_changed():
	cameraInfoPublisher.publish()

func _on_sensor_enabled(enabled:bool):
	if not window:
		return
	if enabled:
		infoTimer.stop()
		window.show()
	else:
		infoTimer.start()
		window.hide()

func _on_window_close_requested():
	enable = false

func set_compressed(_compressed):
	compressed = _compressed
	if not imagePublisher or not compressedImagePulibsher:
		return
	if compressed: 
		publisher = compressedImagePulibsher
	else:
		publisher = imagePublisher
	_rename_sensor_publisher()
	
func set_resolution(_resolution):
	resolution = _resolution
	if subViewport:
		subViewport.size = _resolution
	if window:
		window.size = resolution
	
func set_fov(_fov):
	fov = _fov
	if not camera3D:
		return
	camera3D.fov = fov

func _on_always_on_top_button_toggled(button_pressed):
	window.always_on_top = button_pressed

func _on_domain_id_changed(domain_id):
	cameraInfoPublisher.domain_id = domain_id
	
