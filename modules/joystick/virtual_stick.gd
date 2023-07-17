extends ColorRect

@export var buttonTexture:Texture2D
@onready var button:TextureButton = $Circle/MarginContainer/TextureButton
@onready var circle:TextureButton = $Circle

@export var hz:float: set = set_hz
@onready var timer:Timer = $Timer
@export var return_to_x_origin:bool = true
@export var return_to_y_origin:bool = true

signal virutal_joystick_event(x:float, y:float) # ranges [-1,1]

func set_hz(_hz):
	hz = _hz
	if timer:
		timer.wait_time = 1.0/hz
		
func _ready():
	if buttonTexture:
		button.texture_normal = buttonTexture
	timer.wait_time = 1.0/hz
	_last_mouse_position = global_position + size/2

func _on_resized():
	_last_mouse_position = global_position + size/2

func _on_visibility_changed():	
	if visible: 
		get_node("Timer").call_deferred("start")
	else: 
		get_node("Timer").call_deferred("stop")

func _on_timer_timeout():
	var relative_position:Vector2 = _last_mouse_position - global_position
	virutal_joystick_event.emit(relative_position.x/size.x*2.0-1.0, -relative_position.y/size.y*2.0+1.0)
	
var _last_mouse_position:Vector2
func _on_circle_gui_input(event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if event is InputEventMouseMotion:
			_last_mouse_position = get_viewport().get_mouse_position()
			_last_mouse_position = _last_mouse_position.clamp(global_position, global_position + size)
			button.global_position = _last_mouse_position - button.size/2
	
func _on_joystick_down():
	button.global_position = get_viewport().get_mouse_position() - button.size/2
	_last_mouse_position = get_viewport().get_mouse_position()

func _on_joystick_up():
	if return_to_x_origin:
		button.global_position.x = global_position.x + size.x/2 - button.size.x/2
	if return_to_y_origin:
		button.global_position.y = global_position.y + size.y/2 - button.size.y/2
	_last_mouse_position = global_position + size/2


