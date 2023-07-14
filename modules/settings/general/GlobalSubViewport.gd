class_name GlobalSubViewport extends SubViewport

func _enter_tree():
	world_3d = get_parent().get_window().world_3d
	GraphicsSettings.viewports.append(get_viewport())

func _exit_tree():
	GraphicsSettings.viewports.erase(get_viewport())
