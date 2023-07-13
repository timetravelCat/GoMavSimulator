extends Node

func recursive_release_focus(node:Control):
	node.release_focus()
	for child in node.get_children():
		recursive_release_focus(child)
