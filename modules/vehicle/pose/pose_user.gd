extends Node

@export var control:bool = true
@export var speed:float = 5.0
@export var drag_sensitivity:float = 0.05

func _process(delta):
	if not control or not get_parent():
		return
	var direction = Vector3.ZERO
	if Input.is_key_pressed(KEY_W): 	direction.z -= 1
	if Input.is_key_pressed(KEY_S): 	direction.z += 1
	if Input.is_key_pressed(KEY_A): 	direction.x -= 1
	if Input.is_key_pressed(KEY_D): 	direction.x += 1
	if Input.is_key_pressed(KEY_SPACE): direction.y += 1
	if Input.is_key_pressed(KEY_C): 	direction.y -= 1
	direction = direction.normalized()
	get_parent().global_position += get_parent().global_transform.basis*direction*speed*delta

	var angle = 0.0
	if Input.is_key_pressed(KEY_Q):	angle += 1.0
	if Input.is_key_pressed(KEY_E):	angle -= 1.0
	get_parent().global_transform.basis = get_parent().global_transform.basis * Basis(Vector3(0.0, 0.0, 1.0), angle*drag_sensitivity)

func _input(event):
	if not control or not get_parent():
		return

	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			# Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			var axis = event.relative.normalized()
			if axis.length_squared() > 0.25:
				get_parent().global_transform.basis = get_parent().global_transform.basis * Basis(Vector3(-axis.y, -axis.x, 0.0), drag_sensitivity)
#	else:
#		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
