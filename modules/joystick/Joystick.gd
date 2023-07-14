extends Control

@onready var _Normal:TextureRect = $Container/LRUD/Normal
@onready var _L:TextureRect = $Container/LRUD/L
@onready var _R:TextureRect = $Container/LRUD/R
@onready var _U:TextureRect = $Container/LRUD/U
@onready var _D:TextureRect = $Container/LRUD/D
@onready var _LButton:Button = $Container/LRUD/LB
@onready var _RButton:Button = $Container/LRUD/RB
@onready var _UButton:Button = $Container/LRUD/UB
@onready var _DButton:Button = $Container/LRUD/DB
@onready var _AButton:TextureButton = $Container/ABXY/A
@onready var _BButton:TextureButton = $Container/ABXY/B
@onready var _XButton:TextureButton = $Container/ABXY/X
@onready var _YButton:TextureButton = $Container/ABXY/Y

@onready var _LCircle:TextureRect = $Container/LB
@onready var _LStick:TextureButton = $Container/LB/L
@onready var _RCircle:TextureRect = $Container/RB
@onready var _RStick:TextureButton = $Container/RB/R
@onready var _Disconnect:TextureRect = $Disconnect


func _on_lrud_button_up():
	_Normal.show()
	_L.hide()
	_R.hide()
	_U.hide()
	_D.hide()

func _on_lb_button_down():
	_Normal.hide()
	_L.show()
func _on_rb_button_down():
	_Normal.hide()
	_R.show()
func _on_ub_button_down():
	_Normal.hide()
	_U.show()
func _on_db_button_down():
	_Normal.hide()
	_D.show()

func _on_lb_pressed():
	pass # Replace with function body.
func _on_rb_pressed():
	pass # Replace with function body.
func _on_ub_pressed():
	pass # Replace with function body.
func _on_db_pressed():
	pass # Replace with function body.
	
func _on_a_pressed():
	pass # Replace with function body.
func _on_b_pressed():
	pass # Replace with function body.
func _on_x_pressed():
	pass # Replace with function body.
func _on_y_pressed():
	pass # Replace with function body.

func _on_lb_gui_input(event):
	pass # Replace with function body.
func _on_rb_gui_input(event):
	pass # Replace with function body.





