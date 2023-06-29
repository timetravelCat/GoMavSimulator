extends Control

@export var tab:TabContainer
@export var general:Control
@export var mavlink:Control
@export var simulator:Control

func _on_quit_button_pressed():
	get_tree().quit()

func _on_back_button_pressed():
	hide()

func _on_reset_button_pressed():
	match tab.current_tab:
		0: # General
			general.reset_to_default()
		1: # Mavlink
			mavlink.reset_to_default()
		2: # Simulator
			simulator.reset_to_default()
