extends SubViewport

func _enter_tree():
	GeneralSettings.viewports.append(self)
func _exit_tree():
	GeneralSettings.viewports.erase(self)
