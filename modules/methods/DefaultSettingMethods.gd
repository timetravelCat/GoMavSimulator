class_name DefaultSettingMethods

static func reset_default_property(node:Node, settings:Dictionary):
	for setting in settings:
		if settings[setting] is Dictionary:
			node.set(setting, settings[setting].duplicate(true))
		else:
			node.set(setting, settings[setting])

static func load_default_property(node:Node, settings:Dictionary, path:String):
	if not FileAccess.file_exists(path):
		reset_default_property(node, settings)
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
			if data.has(setting):
				node.set(setting, data[setting])
			else:
				node.set(setting, settings[setting])

static func save_default_property(node:Node, settings:Dictionary, path:String):
	var file_access = FileAccess.open(path, FileAccess.WRITE)
	@warning_ignore("unassigned_variable")
	var data:Dictionary
	for setting in settings:
		if not compare(node.get(setting), settings[setting]):
			data.merge({setting: node.get(setting)})
	file_access.store_line(JSON.stringify(data))

static func compare(left, right)->bool:
	if left is Dictionary and right is Dictionary:
		return left.hash() == right.hash()
	else:
		return left == right
