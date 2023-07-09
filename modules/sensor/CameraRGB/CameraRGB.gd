extends Sensor

@onready var subViewport:SubViewport = $SubViewport
@onready var imagePublisher:ImagePublisher = $SubViewport/ImagePublisher
@onready var compressedImagePulibsher:CompressedImagePublisher = $SubViewport/CompressedImagePublisher
@onready var cameraInfoPublisher:CameraInfoPublisher = $SubViewport/CameraInfoPublisher
@onready var camera3D:Camera3D = $SubViewport/Camera3D
@onready var window:Window = $Window
@onready var infoTimer:Timer = $Timer

@export var compressed:bool = false:
	set(_compressed):
		compressed = _compressed
		if not imagePublisher or not compressedImagePulibsher:
			return
		if compressed: 
			publisher = compressedImagePulibsher
		else:
			publisher = imagePublisher

@export var resolution:Vector2i = Vector2i(640, 360):
	set(_resolution):
		resolution = _resolution
		if not subViewport:
			return
		subViewport.size = _resolution
		window.size = resolution

@export var fov:float = 75.0:
	set(_fov):
		fov = _fov
		if not camera3D:
			return
		camera3D.fov = fov

func _enter_tree():
	get_parent().connect("renamed", _on_vehicle_renamed) # override vehicle renamed feature

func _on_vehicle_renamed():
	_on_renamed() 
	if get_parent() and !get_parent().name.is_empty() and cameraInfoPublisher:
		cameraInfoPublisher.topic_name = get_parent().name + "/camera_info"	
		if window:
			window.title = publisher.topic_name

func _ready():
	compressed = compressed # mannualy call setter
	subViewport.size = resolution
	window.size = resolution
	subViewport.world_3d = get_viewport().world_3d
	_on_vehicle_renamed()
	timer.timeout.connect(_on_timeout)
	sensor_enabled.connect(_on_sensor_enabled)
	
func _on_timeout():
	publisher.publish()
	if publisher is CompressedImagePublisher:
		print("comp")
	
# slow publisher timer for camera info publisher
func _on_timer_timeout():
	cameraInfoPublisher.publish()

func _on_sub_viewport_size_changed():
	cameraInfoPublisher.publish()

func _on_sensor_enabled(enabled:bool):
	if enabled:
		infoTimer.stop()
		window.show()
	else:
		infoTimer.start()
		window.hide()

func _on_window_close_requested():
	enable = false
