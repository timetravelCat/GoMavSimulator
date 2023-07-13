extends Sensor

var property_saved_list:Dictionary = {
	"position":Vector3(0.0, 0.0, 0.0),
	"quaternion":Quaternion(0.0, 0.0, 0.0, 1.0),
	"hz":10.0,
	"enable":true,
	"distance":100.0,
	"vertical_fov":0.0, #degree
	"resolution":Vector2i(72,1),
}

@onready var pointCloudPublisher = $PointCloudPublisher
@onready var rayCastContainer = $RayCastContainer

@export var distance:float = 100.0:
	set(_distance):
		distance = _distance
		_initialize()
		
@export var vertical_fov:float = 0.0: #degree
	set(_vertical_fov):
		vertical_fov = _vertical_fov
		_initialize()
		
@export var resolution:Vector2i = Vector2i(72,1):
	set(_resolution):
		if _resolution.y < 0:
			_resolution.y = 1
		if _resolution.y % 2 == 0: # supports only odd num
			_resolution.y -= 1;
		resolution = _resolution
		_initialize()

func _initialize():
	# remove if container has raycasts
	if not rayCastContainer:
		return
	
	for raycast in rayCastContainer.get_children():
		raycast.queue_free()
	
	# register raycasts depending on the settings
	for width in resolution.x:
		var angle_z:float = 0.0
		var angle_y:float = width*2.0*PI/resolution.x
		var raycast = RayCast3D.new()
		raycast.target_position = Basis.from_euler(Vector3(0.0, angle_y, angle_z), EULER_ORDER_YZX)*Vector3(distance,0.0,0.0)
		rayCastContainer.add_child(raycast)
	
	@warning_ignore("integer_division")
	for height in (resolution.y - 1)/2: #height : 0,1
		var angle_z:float = (height + 1.0)*(deg_to_rad(vertical_fov)/(resolution.y - 1))
		for width in resolution.x:
			var angle_y:float = width*2.0*PI/resolution.x
			var raycast_up = RayCast3D.new()
			var raycast_down = RayCast3D.new()
			raycast_up.target_position = Basis.from_euler(Vector3(0.0, angle_y, angle_z), EULER_ORDER_YZX)*Vector3(distance,0.0,0.0)
			raycast_down.target_position = Basis.from_euler(Vector3(0.0, angle_y, -angle_z), EULER_ORDER_YZX)*Vector3(distance,0.0,0.0)
			rayCastContainer.add_child(raycast_up)
			rayCastContainer.add_child(raycast_down)

func _ready():
	#TODO implement save-load
	super._ready()
	_initialize()

# TODO implement in GDExtension if high-resolution case is burden to cpu.
var _pointcloud:PackedVector3Array
func _on_timeout():
	var raycasts = rayCastContainer.get_children() 
	_pointcloud.resize(raycasts.size())
	for i in raycasts.size():
		_pointcloud[i] = raycasts[i].get_collision_point() - global_position
	pointCloudPublisher.publish(_pointcloud)
