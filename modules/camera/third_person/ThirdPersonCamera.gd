@icon("./ThirdPersonCameraIcon.svg")
class_name ThirdPersonCamera extends Camera3D

@export var control:bool = true
@export var follow:Node3D
@export var distance:float = 10.0
@export var offset:Vector2 
@export_range(-180.0,180.0,5.0,"suffix:°") var azimuth:float
@export_range(-90.0,90.0,5.0,"suffix:°") var elevation:float
@export_range(-90.0,90.0,5.0,"suffix:°") var tilt:float

@export var drag_sensitivity:float = 0.1
@export var zoom_sensitivity:float = 0.02

@warning_ignore("unused_parameter")
func _process(delta):
	if not follow:
		return
	global_transform = Transform3D(
		Basis.from_euler(Vector3(deg_to_rad(-elevation + tilt),deg_to_rad(-90.0 + azimuth),0.0), EULER_ORDER_YXZ),
		follow.global_position + Basis.from_euler(Vector3(0.0, deg_to_rad(azimuth), deg_to_rad(-elevation)), EULER_ORDER_YXZ)*Vector3(-distance, offset.x, offset.y)
	)

func _input(event):
	if not get_window().has_focus() or not current:
		return
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
#			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			azimuth -= drag_sensitivity*event.relative.x
			tilt -= drag_sensitivity*event.relative.y
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
#			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			azimuth -= drag_sensitivity*event.relative.x
			elevation += drag_sensitivity*event.relative.y
	else:
#		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if event is InputEventMouseButton:
			if event.pressed:
				match event.button_index:
					MOUSE_BUTTON_WHEEL_DOWN:
						distance += exp(distance*zoom_sensitivity)
					MOUSE_BUTTON_WHEEL_UP:
						distance -= exp(distance*zoom_sensitivity)
				distance = clampf(distance, 0.0, 1000)
