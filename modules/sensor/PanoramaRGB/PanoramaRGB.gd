class_name PanoramaRGB extends Sensor

@export var property_saved_list:Dictionary = {
	"position":Vector3(0.0, 0.0, 0.0),
	"quaternion":Quaternion(0.0, 0.0, 0.0, 1.0),
	"frame_id":"/map",
	"hz":10.0,
	"enable":true,
	"resolution":320,
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

func _on_timer_timeout():
	publisher.publish()

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
