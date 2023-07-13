extends Node

func reset_default_property(node:Node, settings:Dictionary, path:String):
	for setting in settings:
		node.set(setting, settings[setting])

func load_default_property(node:Node, settings:Dictionary, path:String):
	if not FileAccess.file_exists(path):
		reset_default_property(node, settings, path)
		return
	var file_access := FileAccess.open(path, FileAccess.READ)
	while file_access.get_position() < file_access.get_length():
		var json_string = file_access.get_line()
		var json:JSON = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			continue
		var data = json.get_data()
		for setting in settings:
			node.set(setting, data[setting])

func save_default_property(node:Node, settings:Dictionary, path:String):
	var file_access = FileAccess.open(path, FileAccess.WRITE)
	var data:Dictionary
	for setting in settings:
		data.merge({setting: node.get(setting)})
	file_access.store_line(JSON.stringify(data))
