extends MarkerPublisher


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	publish(Vector3(-1.0, 0.0, 0.0), Quaternion(0.0, 0.0, 0.0, 1.0))
	pass
