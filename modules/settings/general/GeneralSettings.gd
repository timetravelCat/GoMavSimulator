extends Node


@export var default_settings:Dictionary = {
	"world" : 0,
	"district" : 0,
}
@export var save_path:String;

@export_category("World")
@export var worlds:Array[PackedScene] = []
@export var world:int: set = _world_initialize
var current_world:Node3D
signal world_changed

@export_category("District")
@export var district_size:Vector3
@export var districts:Array[PackedScene] = []
@export var district:int: set = _district_initialize
var current_district:Node3D
var district_AABB:AABB 
signal district_changed

# global methods
func create_new_viewer():
	_create_new_viewer()
func set_day_night(value:float):
	_set_day_night(value)
func publish_district():
	_publish_district()

func reset():
	DefaultSettingMethods.reset_default_property(self,default_settings)

func _ready():
	DefaultSettingMethods.load_default_property(self,default_settings,save_path)

func _world_initialize(_world:int):
	world = _world
	if current_world:
		current_world.free()
	current_world = worlds[world].instantiate()
	current_world.name = "world"
	add_child(current_world)
	world_changed.emit()
	
func _district_initialize(_district:int):
	district = _district
	if current_district:
		current_district.free()
		
	district_AABB.position = Vector3(0.0,0.0,0.0)
	district_AABB.end = Vector3(0.0,0.0,0.0)
	current_district = districts[district].instantiate()
	current_district.name = "district"
	_create_collision_body(current_district)
	add_child(current_district)
	district_changed.emit()

func _create_collision_body(district_child:Node):
	var meshInstance = district_child as MeshInstance3D
	if meshInstance: 
		meshInstance.create_trimesh_collision()
		
		# Get total aabb size of district
		if meshInstance.mesh:
			var aabb:AABB = meshInstance.mesh.get_aabb()
			if absf(aabb.position.x) < district_size.x and absf(aabb.position.y) < district_size.y and absf(aabb.position.z) < district_size.z:
				if absf(aabb.end.x) < district_size.x and absf(aabb.end.y) < district_size.y and absf(aabb.end.z) < district_size.z:
					district_AABB.position.x = minf(district_AABB.position.x, aabb.position.x)
					district_AABB.position.y = minf(district_AABB.position.y, aabb.position.y)
					district_AABB.position.z = minf(district_AABB.position.z, aabb.position.z)
					district_AABB.position.x = minf(district_AABB.position.x, aabb.end.x)
					district_AABB.position.y = minf(district_AABB.position.y, aabb.end.y)
					district_AABB.position.z = minf(district_AABB.position.z, aabb.end.z)
					
					district_AABB.end.x = maxf(district_AABB.end.x, aabb.position.x)
					district_AABB.end.y = maxf(district_AABB.end.y, aabb.position.y)
					district_AABB.end.z = maxf(district_AABB.end.z, aabb.position.z)
					district_AABB.end.x = maxf(district_AABB.end.x, aabb.end.x)
					district_AABB.end.y = maxf(district_AABB.end.y, aabb.end.y)
					district_AABB.end.z = maxf(district_AABB.end.z, aabb.end.z)
	
	for child in district_child.get_children():
		_create_collision_body(child)

var _viewer:PackedScene = preload("res://modules/viewer/Viewer.tscn")
var _viewer_position:Vector2i = Vector2i.ZERO
func _create_new_viewer():
	var viewer = _viewer.instantiate()
	viewer.position = get_window().position + _viewer_position;
	_viewer_position += Vector2i(32, 24)
	if _viewer_position.x > 640:
		_viewer_position = Vector2i.ZERO
	add_child(viewer)
	
func _set_day_night(value):
	current_world.day_night = value

@onready var district_publisher:MarkerPublisher = $DistrictPublisher
func _publish_district():
	district_publisher.surface = current_district
	district_publisher.publish(current_district.position, current_district.quaternion)
