extends PointStampedSubscriber


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("on_data_subscribed", _on_data_subscribed)
	
	# initialized called automatically if topic_name assigned in editor, 
	# however if you set topic_name by code, after _enter_tree, calling initalize may be required.
	initialize()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_data_subscribed(point):
	print(point)
	pass # Replace with function body.
