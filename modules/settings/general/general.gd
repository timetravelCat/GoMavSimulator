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
@export var general_quality:OptionButton
@export var shadows:OptionButton
@export var visual_effects:OptionButton
@export var anti_alising:OptionButton
@export var ambient_occlusion:OptionButton
@export var texture:OptionButton

@export var settings:Theme
@export var subtitle:LabelSettings

@export var world_environment:WorldEnvironment
var viewports:Array

func reset_to_default():
	# WINDOWED MODE
	fullscreen.select(0)
	fullscreen.item_selected.emit(0)
	
	# 1920x1080
	screen_resolution.select(1)
	screen_resolution.item_selected.emit(1)
	
	# pass main_window
	
	# VERTICAL SYNC ON
	vertical_sync_on.pressed.emit()
	
	# maximum 60hz as default
	frame_rate_limitation.select(1)
	frame_rate_limitation.item_selected.emit(1)
	
	# UI SCALING as half value of its maxium
	ui_scaling.value = ui_scaling.max_value/2.0
	
	# MINIMAP ON
	minimap_on.pressed.emit()
	
	# GENERAL QUALITY AS MEDIUM
	general_quality.select(2)
	general_quality.item_selected.emit(2)
	pass

func _ready():
	# prepare main_window
	for i in DisplayServer.get_screen_count():
		var res = DisplayServer.screen_get_size(i)
		main_window.add_item(str(i) + " : " + str(res.x) + "x" + str(res.y))
	
	# Register main camera viewport (TODO find better place)
	viewports.append(get_viewport())		

	pass

func _on_fullscreen_item_selected(index):
	match index:
			0:
				DisplayServer.call_deferred("window_set_mode", DisplayServer.WINDOW_MODE_WINDOWED)
			1:
				DisplayServer.call_deferred("window_set_mode", DisplayServer.WINDOW_MODE_FULLSCREEN)
	pass

func _on_resolution_item_selected(index):
	DisplayServer.call_deferred("window_set_mode", DisplayServer.WINDOW_MODE_WINDOWED)
	match index:
			0: # 2560x1440
				DisplayServer.call_deferred("window_set_size", Vector2i(2560,1440))
			1: # 1920x1080
				DisplayServer.call_deferred("window_set_size", Vector2i(1920,1080))
			2: # 1600x900
				DisplayServer.call_deferred("window_set_size", Vector2i(1600,900))
			3: # 1366x768
				DisplayServer.call_deferred("window_set_size", Vector2i(1366,768))
			4: # 1280x720
				DisplayServer.call_deferred("window_set_size", Vector2i(1280,720))
	pass

func _on_window_item_selected(index):
	var window_size:Vector2i = DisplayServer.window_get_size()
	var screen_size:Vector2i = DisplayServer.screen_get_size(index)
	
	var set_fullscreen:bool = false
	# Get Centor location if scrren_size is bigger than window size
	if screen_size.x < window_size.x || screen_size.y < window_size.y:
		set_fullscreen = true
	
	DisplayServer.call_deferred("window_set_current_screen", index)
	if set_fullscreen:
		DisplayServer.call_deferred("window_set_mode", DisplayServer.WINDOW_MODE_FULLSCREEN)
	pass

func _on_vsync_on_pressed():
	DisplayServer.call_deferred("window_set_vsync_mode", DisplayServer.VSYNC_ENABLED)
	vertical_sync_on.disabled = true
	vertical_sync_off.disabled = false
	pass

func _on_vsync_off_pressed():
	DisplayServer.call_deferred("window_set_vsync_mode", DisplayServer.VSYNC_DISABLED)
	vertical_sync_on.disabled = false
	vertical_sync_off.disabled = true
	pass

func _on_frame_rate_item_selected(index):
	match index:
		0: # 30
			Engine.call_deferred("set_max_fps", 30)
		1: # 60
			Engine.call_deferred("set_max_fps", 60)
		2: # 72
			Engine.call_deferred("set_max_fps", 72)
		3: # 120
			Engine.call_deferred("set_max_fps", 120)
		4: # 144
			Engine.call_deferred("set_max_fps", 144)
		5: # Unlimited
			Engine.call_deferred("set_max_fps", 0)
	pass

func _on_ui_scaling_value_changed(value):
	const settings_default_font_size:int = 26
	const subtitle_default_font_size:int = 32 
	var ui_scaling_ratio:float = 2.0 * value / ui_scaling.max_value
	settings.default_font_size = clampi(int(ui_scaling_ratio * settings_default_font_size), 1, 2*settings_default_font_size)
	subtitle.font_size = clampi(int(ui_scaling_ratio * subtitle_default_font_size), 1, 2*subtitle_default_font_size)
	pass

func _on_minimap_on_pressed():
	# TODO 23.06.24 minimap feature is not implemented yet.
	minimap_on.disabled = true
	minimap_off.disabled = false
	pass

func _on_minimap_off_pressed():
	# TODO 23.06.24 minimap feature is not implemented yet.
	minimap_on.disabled = false
	minimap_off.disabled = true
	pass

func _on_shadows_item_selected(index):
	# 0(ULTRA) 1 2 3 4 5(DISABLED)
	match index:
		0: # ULTRA
			RenderingServer.directional_shadow_atlas_set_size(16384, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
			# directional_light.shadow_bias = 0.005
			for viewport in viewports:
				viewport.positional_shadow_atlas_size = 16384
		1: # HIGH
			RenderingServer.directional_shadow_atlas_set_size(8192, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
			# directional_light.shadow_bias = 0.01
			for viewport in viewports:
				viewport.positional_shadow_atlas_size = 8192
		2: # MIDIUM
			RenderingServer.directional_shadow_atlas_set_size(4096, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
			# directional_light.shadow_bias = 0.02
			for viewport in viewports:
				viewport.positional_shadow_atlas_size = 4096
		3: # LOW
			RenderingServer.directional_shadow_atlas_set_size(2048, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
			# directional_light.shadow_bias = 0.03
			for viewport in viewports:
				viewport.positional_shadow_atlas_size = 2048
		4: # VERY LOW
			RenderingServer.directional_shadow_atlas_set_size(1024, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
			# directional_light.shadow_bias = 0.04
			for viewport in viewports:
				viewport.positional_shadow_atlas_size = 1024
		5: # DISABLED
			RenderingServer.directional_shadow_atlas_set_size(512, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
			# directional_light.shadow_bias = 0.06
			for viewport in viewports:
				viewport.positional_shadow_atlas_size = 0
	pass 

func _on_anti_alising_item_selected(index):
	match index:
		0: # MXAA_8
			for viewport in viewports:
				viewport.msaa_3d = Viewport.MSAA_8X
				viewport.use_taa = false
				viewport.screen_space_aa = false
		1: # MSAA_4
			for viewport in viewports:
				viewport.msaa_3d = Viewport.MSAA_4X
				viewport.use_taa = false
				viewport.screen_space_aa = false
		2: # MSAA_2
			for viewport in viewports:
				viewport.msaa_3d = Viewport.MSAA_2X
				viewport.use_taa = false
				viewport.screen_space_aa = false
		3: # TAA
			for viewport in viewports:
				viewport.use_taa = true
				viewport.screen_space_aa = false
			pass
		4: # FXAA
			for viewport in viewports:
				viewport.screen_space_aa = true
				viewport.use_taa = false
			pass
		5: # DISABLED
			for viewport in viewports:
				viewport.msaa_3d = Viewport.MSAA_DISABLED
				viewport.screen_space_aa = false
				viewport.screen_space_aa = false
			pass
	pass 

func _on_ambient_occlusion_item_selected(index):
	if world_environment == null:
		return
		
	match index:
		0: # HIGH
			world_environment.environment.ssao_enabled = true
			RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_ULTRA, true, 0.5, 2, 50, 300)
		1: # HIGH
			world_environment.environment.ssao_enabled = true
			RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_HIGH, true, 0.5, 2, 50, 300)
		2: # MEDIUM
			world_environment.environment.ssao_enabled = true
			RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 2, 50, 300)
		3: # LOW
			world_environment.environment.ssao_enabled = true
			RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_LOW, true, 0.5, 2, 50, 300)
		4: # VERY LOW
			world_environment.environment.ssao_enabled = true
			RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_VERY_LOW, true, 0.5, 2, 50, 300)
		5: # DISABLED
			world_environment.environment.ssao_enabled = false
			pass
	pass 

func _on_texture_item_selected(index):
	match index:
		0: # ULTRA
			for viewport in viewports:
				viewport.mesh_lod_threshold = 0.0
			pass
		1: # HIGH
			for viewport in viewports:
				viewport.mesh_lod_threshold = 1.0
			pass
		2: # MEDIUM
			for viewport in viewports:
				viewport.mesh_lod_threshold = 2.0
			pass
		3: # LOW
			for viewport in viewports:
				viewport.mesh_lod_threshold = 4.0
			pass
		4: # VERY LOW
			for viewport in viewports:
				viewport.mesh_lod_threshold = 8.0
			pass
		5: # DISABLED
			for viewport in viewports:
				viewport.mesh_lod_threshold = 8.0
			pass
	pass 

func _on_visual_effects_item_selected(index):
	if world_environment == null:
		return
		
	match index:
		0: # ULTRA
			world_environment.environment.set_ssr_enabled(true)
			world_environment.environment.set_ssr_max_steps(56)
			world_environment.environment.sdfgi_enabled = true
			world_environment.environment.glow_enabled = true
			world_environment.environment.volumetric_fog_enabled = true
			RenderingServer.gi_set_use_half_resolution(false)
			RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_ULTRA, true, 0.5, 4, 50, 300)
			RenderingServer.environment_set_volumetric_fog_filter_active(true)
			pass
		1: # HIGH
			world_environment.environment.set_ssr_enabled(true)
			world_environment.environment.set_ssr_max_steps(32)
			world_environment.environment.ssil_enabled = true
			world_environment.environment.sdfgi_enabled = true
			world_environment.environment.glow_enabled = true
			world_environment.environment.volumetric_fog_enabled = true
			RenderingServer.gi_set_use_half_resolution(false)
			RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_HIGH, true, 0.5, 4, 50, 300)
			RenderingServer.environment_set_volumetric_fog_filter_active(true)
			pass
		2: # MEDIUM
			world_environment.environment.set_ssr_enabled(true)
			world_environment.environment.set_ssr_max_steps(16)
			world_environment.environment.ssil_enabled = true
			world_environment.environment.sdfgi_enabled = true
			world_environment.environment.glow_enabled = true
			world_environment.environment.volumetric_fog_enabled = true
			RenderingServer.gi_set_use_half_resolution(true)
			RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_MEDIUM, true, 0.5, 4, 50, 300)
			RenderingServer.environment_set_volumetric_fog_filter_active(false)
			pass
		3: # LOW
			world_environment.environment.set_ssr_enabled(true)
			world_environment.environment.set_ssr_max_steps(8)
			world_environment.environment.ssil_enabled = true
			world_environment.environment.sdfgi_enabled = true
			world_environment.environment.glow_enabled = true
			world_environment.environment.volumetric_fog_enabled = true
			RenderingServer.gi_set_use_half_resolution(true)
			RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_LOW, true, 0.5, 4, 50, 300)
			RenderingServer.environment_set_volumetric_fog_filter_active(false)
			pass
		4: # VERY LOW
			world_environment.environment.set_ssr_enabled(true)
			world_environment.environment.set_ssr_max_steps(4)
			world_environment.environment.ssil_enabled = true
			world_environment.environment.sdfgi_enabled = false
			world_environment.environment.glow_enabled = false
			world_environment.environment.volumetric_fog_enabled = false
			RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_VERY_LOW, true, 0.5, 4, 50, 300)
		5: # DISABLED
			world_environment.environment.set_ssr_enabled(false)
			world_environment.environment.ssil_enabled = false
			world_environment.environment.sdfgi_enabled = false
			world_environment.environment.glow_enabled = false
			world_environment.environment.volumetric_fog_enabled = false
			pass
	pass

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
	pass 
