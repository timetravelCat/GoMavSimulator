class_name ControlMethods

static func recursive_release_focus(node:Control):
	node.release_focus()
	for child in node.get_children():
		recursive_release_focus(child)

# Common Methods for LineEdit
static func check_valid_string_and_notify(node:LineEdit, string:String)->bool:
	node.release_focus()
	if node.text.is_empty():
		Notification.notify(string, Notification.NOTICE_TYPE.ALERT)
		node.text = ""
		return false
	return true
	
static func check_valid_int_and_notify(node:LineEdit, string:String)->bool:
	node.release_focus()
	if not node.text.is_valid_int() or node.text.is_empty():
		Notification.notify(string, Notification.NOTICE_TYPE.ALERT)
		node.text = ""
		return false
	return true

static func check_valid_float_and_notify(node:LineEdit, string:String)->bool:
	node.release_focus()
	if not node.text.is_valid_float() or node.text.is_empty():
		Notification.notify(string, Notification.NOTICE_TYPE.ALERT)
		node.text = ""
		return false
	return true

## Common Methods for ItemList, return true if anything selcted.
static func check_anything_selected_and_notify(node:ItemList, string:String)->bool:
	if not node.is_anything_selected():
		Notification.notify(string, Notification.NOTICE_TYPE.ALERT)
		return false
	return true

static func get_selected_item_text(node:ItemList)->String:
	return node.get_item_text(node.get_selected_items()[0])
