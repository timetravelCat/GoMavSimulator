extends PointStampedPublisher

var meshInstance3D
var x = 1.0
var z = 0.0
var t = 0.0
# Called when the node enters the scene tree for the first time.
func _ready():
	meshInstance3D = get_node("MeshInstance3D")
	print("reset topic name on publisher")
	topic_name = "point2"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta;
	x = cos(t)
	z = sin(t)
	meshInstance3D.set_position(Vector3(x,0.0,z))
	publish_node3d()
	pass
