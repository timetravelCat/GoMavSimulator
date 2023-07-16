extends Panel
@onready var LStick = $LSTICK
@onready var RStick = $RSTICK
@onready var AButton = $A
@onready var BButton = $B
@onready var XButoon = $X
@onready var YButton = $Y

func _on_lstick_virutal_joystick_event(x, y):
	if x > 0.0:
		var inputEventActionX = InputEventAction.new()
		inputEventActionX.action = "rudder_up"
		inputEventActionX.pressed = true
		inputEventActionX.strength = absf(x)
		Input.parse_input_event(inputEventActionX)	
	elif x < 0.0:
		var inputEventActionX = InputEventAction.new()
		inputEventActionX.action = "rudder_down"
		inputEventActionX.pressed = true
		inputEventActionX.strength = absf(x)
		Input.parse_input_event(inputEventActionX)	
	if y > 0.0:
		var inputEventActionY = InputEventAction.new()
		inputEventActionY.action = "throttle_up"
		inputEventActionY.pressed = true
		inputEventActionY.strength = absf(y)
		Input.call_deferred("parse_input_event", inputEventActionY)
		Input.parse_input_event(inputEventActionY)	
	elif y < 0.0:
		var inputEventActionY = InputEventAction.new()
		inputEventActionY.action = "throttle_down"
		inputEventActionY.pressed = true
		inputEventActionY.strength = absf(y)
		Input.call_deferred("parse_input_event", inputEventActionY)
		Input.parse_input_event(inputEventActionY)	
func _on_rstick_virutal_joystick_event(x, y):
	if x > 0.0:
		var inputEventActionX = InputEventAction.new()
		inputEventActionX.action = "aileron_up"
		inputEventActionX.pressed = true
		inputEventActionX.strength = absf(x)
		Input.parse_input_event(inputEventActionX)	
	elif x < 0.0:
		var inputEventActionX = InputEventAction.new()
		inputEventActionX.action = "aileron_down"
		inputEventActionX.pressed = true
		inputEventActionX.strength = absf(x)
		Input.parse_input_event(inputEventActionX)	
	if y > 0.0:
		var inputEventActionY = InputEventAction.new()
		inputEventActionY.action = "elevator_up"
		inputEventActionY.pressed = true
		inputEventActionY.strength = absf(y)
		Input.call_deferred("parse_input_event", inputEventActionY)
		Input.parse_input_event(inputEventActionY)	
	elif y < 0.0:
		var inputEventActionY = InputEventAction.new()
		inputEventActionY.action = "elevator_down"
		inputEventActionY.pressed = true
		inputEventActionY.strength = absf(y)
		Input.call_deferred("parse_input_event", inputEventActionY)
		Input.parse_input_event(inputEventActionY)	
	
func _on_a_pressed(): # ARM
	var inputEventAction = InputEventAction.new()
	inputEventAction.action = "arm"
	inputEventAction.pressed = true
	Input.parse_input_event(inputEventAction)
func _on_b_pressed(): # DISARM
	var inputEventAction = InputEventAction.new()
	inputEventAction.action = "disarm"
	inputEventAction.pressed = true
	Input.parse_input_event(inputEventAction)
func _on_x_pressed(): # Position Mode
	var inputEventAction = InputEventAction.new()
	inputEventAction.action = "position_mode"
	inputEventAction.pressed = true
	Input.parse_input_event(inputEventAction)
func _on_y_pressed(): # Altitude Mode
	var inputEventAction = InputEventAction.new()
	inputEventAction.action = "altitude_mode"
	inputEventAction.pressed = true
	Input.parse_input_event(inputEventAction)
