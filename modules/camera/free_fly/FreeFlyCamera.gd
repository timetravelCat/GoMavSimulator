@icon("./FreeFlyCameraIcon.png")
extends Camera3D

@export var follow:Node3D
@export var speed:float = 5.0
@export var drag_sensitivity:float = 0.05

var _basis_offset:Basis = Basis.from_euler(Vector3(0.0,deg_to_rad(-90.0),0.0), EULER_ORDER_YXZ)

func _init():
	global_transform = Transform3D(_basis_offset, Vector3.ZERO)

func reset():
	if follow:
		global_transform = Transform3D(follow.global_transform.basis*_basis_offset, follow.global_position)
	else:
		global_transform = Transform3D(_basis_offset, Vector3.ZERO)

func _process(delta):
	if not get_window().has_focus() or not current:
		return
	var direction = Vector3.ZERO
	if Input.is_key_pressed(KEY_W): 	direction.z -= 1
	if Input.is_key_pressed(KEY_S): 	direction.z += 1
	if Input.is_key_pressed(KEY_A): 	direction.x -= 1
	if Input.is_key_pressed(KEY_D): 	direction.x += 1
	if Input.is_key_pressed(KEY_SPACE): direction.y += 1
	if Input.is_key_pressed(KEY_C): 	direction.y -= 1
	direction = direction.normalized()
	global_position += global_transform.basis*direction*speed*delta

	var angle = 0.0
	if Input.is_key_pressed(KEY_Q):	angle += 1.0
	if Input.is_key_pressed(KEY_E):	angle -= 1.0
	global_transform.basis = global_transform.basis * Basis(Vector3(0.0, 0.0, 1.0), angle*drag_sensitivity)

func _input(event):
	if not get_window().has_focus() or not current:
		return
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			# Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			var axis = event.relative.normalized()
			if axis.length_squared() > 0.25:
				global_transform.basis = global_transform.basis * Basis(Vector3(-axis.y, -axis.x, 0.0), drag_sensitivity)
#	else:
#		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
# TODO ADD mouse wheel action.
# RayCast3D? see any collider exists and zoom in / out
