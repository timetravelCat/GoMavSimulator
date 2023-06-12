extends PathPublisher

var path
# Called when the node enters the scene tree for the first time.
func _ready():
	path = PackedVector3Array()
	path.append(Vector3(0.0, 1.0, 0.0))
	path.append(Vector3(0.0, 2.0, 0.0))
	path.append(Vector3(0.0, 3.0, 1.0))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	publish(path)
	pass
