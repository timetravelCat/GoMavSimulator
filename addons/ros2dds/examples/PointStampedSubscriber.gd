extends PointStampedSubscriber


# Called when the node enters the scene tree for the first time.
func _ready():
	topic_name = "point2"
	connect("on_data_subscribed", _on_data_subscribed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_data_subscribed(point):
	print(point)
	pass # Replace with function body.
