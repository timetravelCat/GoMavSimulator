extends Control

# !WARNING!
# Do not directly inherit GDExtension nodes, at the moment of writing(2023.07.19), has bug on GDExtension.
# Do not create @onready, static obejct includes GDExtension Nodes either. Use @export or get_node instead.
@onready var button:Button = $Button
func _on_button_pressed():
	button.text = str(SerialPort.list_ports())
