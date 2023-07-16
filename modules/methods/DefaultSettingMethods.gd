class_name DefaultSettingMethods


static func get_property_data(node:Node, settings:Dictionary)->Dictionary:
	@warning_ignore("unassigned_variable")
	var data:Dictionary
	for setting in settings:
		if not compare(node.get(setting), settings[setting]):
			data.merge({setting: node.get(setting)})
	return data

static func reset_default_property(node:Node, settings:Dictionary):
	for setting in settings:
		if settings[setting] is Dictionary:
			node.set(setting, settings[setting].duplicate(true))
		else:
			node.set(setting, settings[setting])

static func load_default_property(node:Node, settings:Dictionary, path:String):
	if path.is_empty():
		return
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
	if path.is_empty():
		return
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

static func string_to_vector(string:String):
	if string.is_empty():
		return null
	var str_copy = string as String
	str_copy = str_copy.erase(0, 1) # remove first "("
	str_copy = str_copy.erase(str_copy.length()-1, 1) # remove last ")"
	var values:Array = str_copy.split(", ")
	if values.size() == 2:
		return Vector2(values[0].to_float(), values[1].to_float())
	elif values.size() == 3:
		return Vector3(values[0].to_float(), values[1].to_float(), values[2].to_float())
	elif values.size() == 4:
		return Quaternion(values[0].to_float(), values[1].to_float(), values[2].to_float(), values[3].to_float())
	return null
