extends SubViewport

func _enter_tree():
	GraphicsSettings.viewports.append(self)
func _exit_tree():
	GraphicsSettings.viewports.erase(self)
