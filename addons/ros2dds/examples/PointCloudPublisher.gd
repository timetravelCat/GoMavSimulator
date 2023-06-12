extends PointCloudPublisher

var pointCloud
# Called when the node enters the scene tree for the first time.
func _ready():
	pointCloud = PackedVector3Array()
	pointCloud.append(Vector3(0.0, 0.0, 1.0))
	pointCloud.append(Vector3(0.0, 0.0, 1.1))
	pointCloud.append(Vector3(0.0, 0.0, 1.2))
	pointCloud.append(Vector3(0.0, 0.0, 1.3))
	pointCloud.append(Vector3(0.0, 0.0, 1.4))
	pointCloud.append(Vector3(0.1, 0.0, 1.5))
	pointCloud.append(Vector3(0.2, 0.0, 1.5))
	pointCloud.append(Vector3(0.3, 0.0, 1.5))
	pointCloud.append(Vector3(0.4, 0.0, 1.5))
	pointCloud.append(Vector3(0.5, 0.0, 1.5))
	pointCloud.append(Vector3(0.6, 0.0, 1.5))
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	publish(pointCloud)
	pass
