extends VehiclePose

# signal pose_update(position, quaternion)
var stop:bool

var position:Vector3
var quaternion:Quaternion

func _set_enable(enable:bool):
	stop = !enable

func _get_enable()->bool:
	return !stop

@export var speed:float = 5.0
@export var drag_sensitivity:float = 0.05

func _process(delta):
	if stop or not get_window().has_focus():
		armed_updated.emit(false)
		return
	var direction = Vector3.ZERO
	if Input.is_key_pressed(KEY_W): 	direction.x += 1
	if Input.is_key_pressed(KEY_S): 	direction.x -= 1
	if Input.is_key_pressed(KEY_A): 	direction.z -= 1
	if Input.is_key_pressed(KEY_D): 	direction.z += 1
	if Input.is_key_pressed(KEY_SPACE): direction.y += 1
	if Input.is_key_pressed(KEY_C): 	direction.y -= 1
	direction = direction.normalized()	
	position += quaternion*(direction*speed*delta)
	pose_update.emit(position, quaternion)
	armed_updated.emit(true)

func _input(event):
	if stop or not get_window().has_focus():
		return
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			# Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			var axis = event.relative.normalized()
			if axis.length_squared() > 0.25:
				# get current camera's rotation and rotate.
				var camera = get_viewport().get_camera_3d() as Camera3D
				if camera:
					quaternion = Quaternion(Basis(camera.quaternion*Vector3(axis.y, axis.x, 0.0), drag_sensitivity)) * quaternion
					pose_update.emit(position, quaternion)
