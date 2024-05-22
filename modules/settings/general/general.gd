extends Control

@export var fullscreen:OptionButton
@export var screen_resolution:OptionButton
@export var main_window:OptionButton
@export var vertical_sync_on:Button
@export var vertical_sync_off:Button
@export var frame_rate_limitation:OptionButton
@export var ui_scaling:HSlider
@export var minimap_on:Button
@export var minimap_off:Button
@export var minimap_scale:HSlider
@export var minimap_transparency:HSlider
@export var noon_to_sunset:HSlider
@export var general_quality:OptionButton
@export var shadows:OptionButton
@export var visual_effects:OptionButton
@export var anti_alising:OptionButton
@export var ambient_occlusion:OptionButton
@export var texture:OptionButton

@export var settings:Theme
@export var subtitle:LabelSettings

var scrren_resoultion_option:Dictionary = {
	0:Vector2i(2560, 1440),
	1:Vector2i(1920, 1080),
	2:Vector2i(1600, 900),
	3:Vector2i(1366, 768),
	4:Vector2i(1280, 720)
}

var frame_rate_limitation_option:Dictionary = {
	0:30,
	1:60,
	2:72,
	3:120,
	4:144
}

func reset_to_default():
	GeneralSettings.reset()
	GraphicsSettings.reset()
	_ready()

func _ready():
	# prepare fullscreen mode 
	fullscreen.clear()
	fullscreen.add_item(" WINDOWED ")
	fullscreen.add_item(" FULLSCRREN ")
	fullscreen.selected = GraphicsSettings.fullscreen
	
	# prepare screen resolution
	screen_resolution.clear()
	var screen_resolution_selected = 0
	for key in scrren_resoultion_option:
		var resolution = scrren_resoultion_option[key]
		screen_resolution.add_item(str(resolution.x)+"x"+str(resolution.y))
		if GraphicsSettings.screen_resolution.x == resolution.x and GraphicsSettings.screen_resolution.y == resolution.y:
			screen_resolution_selected = screen_resolution.item_count - 1
	screen_resolution.selected = screen_resolution_selected
		
	# prepare main_window list
	main_window.clear()
	for i in DisplayServer.get_screen_count():
		var res = DisplayServer.screen_get_size(i)
		main_window.add_item(str(i) + " : " + str(res.x) + "x" + str(res.y))
	main_window.selected = GraphicsSettings.main_window 
	
	# prepare vsync
	vertical_sync_on.disabled = GraphicsSettings.vertical_sync
	vertical_sync_off.disabled = !GraphicsSettings.vertical_sync
	
	# preapre frame_rate_limitation
	frame_rate_limitation.clear()
	var frame_rate_limitation_selcted = 0
	for key in frame_rate_limitation_option:
		var frame_rate = frame_rate_limitation_option[key]
		frame_rate_limitation.add_item(str(frame_rate))
		if GraphicsSettings.frame_rate_limitation == frame_rate:
			frame_rate_limitation_selcted = frame_rate_limitation.item_count - 1
	frame_rate_limitation.selected = frame_rate_limitation_selcted
	
	# Load scaling value
	ui_scaling.value = GraphicsSettings.ui_scaling
	const settings_default_font_size:int = 26
	const subtitle_default_font_size:int = 32 
	var ui_scaling_ratio:float = 2.0 * ui_scaling.value / ui_scaling.max_value
	settings.default_font_size = clampi(int(ui_scaling_ratio * settings_default_font_size), 1, 2*settings_default_font_size)
	subtitle.font_size = clampi(int(ui_scaling_ratio * subtitle_default_font_size), 1, 2*subtitle_default_font_size)
	
	# minimap setting
	minimap_on.disabled = GeneralSettings.minimap
	minimap_off.disabled = !GeneralSettings.minimap
	
	# Quality Settings
	shadows.selected = GraphicsSettings.shadow
	visual_effects.selected = GraphicsSettings.visual_effects
	anti_alising.selected = GraphicsSettings.anti_alising
	ambient_occlusion.selected = GraphicsSettings.ambient_occlusion
	texture.selected = GraphicsSettings.texture
	
	# general setting - set as average of other qualities
	@warning_ignore("integer_division")
	general_quality.selected = clampi((shadows.selected + visual_effects.selected + anti_alising.selected + ambient_occlusion.selected + texture.selected)/5, 0, 5)
	
func _on_fullscreen_item_selected(index):
	GraphicsSettings.set_fullscreen(index)

func _on_resolution_item_selected(index):
	GraphicsSettings.set_screen_resolution(scrren_resoultion_option[index])

func _on_window_item_selected(index):
	GraphicsSettings.set_main_window(index)

func _on_vsync_on_pressed():
	vertical_sync_on.disabled = true
	vertical_sync_off.disabled = false
	GraphicsSettings.set_vertical_sync(true)

func _on_vsync_off_pressed():
	vertical_sync_on.disabled = false
	vertical_sync_off.disabled = true
	GraphicsSettings.set_vertical_sync(false)

func _on_frame_rate_item_selected(index):
	GraphicsSettings.set_frame_rate_limitation(frame_rate_limitation_option[index])

func _on_ui_scaling_value_changed(value):
	@warning_ignore("narrowing_conversion")
	GraphicsSettings.ui_scaling = ui_scaling.value
	const settings_default_font_size:int = 26
	const subtitle_default_font_size:int = 32 
	var ui_scaling_ratio:float = 2.0 * ui_scaling.value / ui_scaling.max_value
	settings.default_font_size = clampi(int(ui_scaling_ratio * settings_default_font_size), 1, 2*settings_default_font_size)
	subtitle.font_size = clampi(int(ui_scaling_ratio * subtitle_default_font_size), 1, 2*subtitle_default_font_size)

func _on_minimap_on_pressed():
	GeneralSettings.minimap = true
	minimap_on.disabled = true
	minimap_off.disabled = false

func _on_minimap_off_pressed():
	GeneralSettings.minimap = false
	minimap_on.disabled = false
	minimap_off.disabled = true

func _on_shadows_item_selected(index):
	GraphicsSettings.set_shadow(index)

func _on_anti_alising_item_selected(index):
	GraphicsSettings.set_anti_alising(index)

func _on_ambient_occlusion_item_selected(index):
	GraphicsSettings.set_ambient_occlusion(index)

func _on_texture_item_selected(index):
	GraphicsSettings.set_texture(index)

func _on_visual_effects_item_selected(index):
	GraphicsSettings.set_visual_effects(index)

func _on_overall_quality_item_selected(index):
	shadows.select(index)
	shadows.item_selected.emit(index)
	
	anti_alising.select(index)
	anti_alising.item_selected.emit(index)
	
	ambient_occlusion.select(index)
	ambient_occlusion.item_selected.emit(index)
	
	texture.select(index)
	texture.item_selected.emit(index)
	
	visual_effects.select(index)
	visual_effects.item_selected.emit(index)

func _on_open_new_viewer_pressed():
	GeneralSettings.create_new_viewer()

func _on_minimap_scale_value_changed(value):
	GeneralSettings.minimap_ratio = value / minimap_scale.max_value

func _on_minimap_transparency_value_changed(value):
	GeneralSettings.minimap_alpha = value / minimap_transparency.max_value

func _on_day_night_value_changed(value):
	GraphicsSettings.set_day_night(value / noon_to_sunset.max_value)

func _on_publish_district_pressed():
	pass

func _on_gui_input(event):
	if event is InputEventMouseButton:
		var mouseEvent:InputEventMouse = event
		if event.pressed and mouseEvent.button_index == MOUSE_BUTTON_RIGHT:
			ControlMethods.recursive_release_focus(self)	
