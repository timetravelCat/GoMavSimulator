## A Window class that automatically set world from parent and register to global shared viewports setting.
class_name GlobalWindow extends Window

func _enter_tree():
	world_3d = get_parent().get_window().world_3d
	GraphicsSettings.viewports.append(get_viewport())

func _exit_tree():
	GraphicsSettings.viewports.erase(get_viewport())
