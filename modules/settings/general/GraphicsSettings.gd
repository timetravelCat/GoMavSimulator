extends Node

@export var default_settings:Dictionary = {
	"fullscreen":false,
	"screen_resolution": Vector2i(1600,900),
	"main_window": 0,
	"vertical_sync": true,
	"frame_rate_limitation": 60,
	"ui_scaling": 50,
	"minimap": true,
	"shadow": 2,
	"anti_alising": 2,
	"ambient_occlusion": 2,
	"texture": 2,
	"visual_effects": 2
}
@export var save_path:String;

@export var fullscreen:bool: set = set_fullscreen
@export var screen_resolution:Vector2i: set = set_screen_resolution
@export var main_window:int: set = set_main_window
@export var vertical_sync:bool: set = set_vertical_sync
@export var frame_rate_limitation:int: set = set_frame_rate_limitation
@export var ui_scaling:int: set = set_ui_scaling
@export var minimap:bool: set = set_minimap
@export var shadow:int: set = set_shadow
@export var anti_alising:int: set = set_anti_alising
@export var ambient_occlusion:int: set = set_ambient_occlusion
@export var texture:int: set = set_texture
@export var visual_effects:int: set = set_visual_effects

var viewports:Array[Viewport]

func reset():
	DefaultSettingMethods.reset_default_property(self, default_settings, save_path)

func _ready():
	DefaultSettingMethods.load_default_property(self,default_settings,save_path)
	# Register main window viewport
	viewports.append(get_viewport())	
	
func set_fullscreen(_fullscreen):
	fullscreen = _fullscreen
	if fullscreen:
		DisplayServer.call_deferred("window_set_mode", DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.call_deferred("window_set_mode", DisplayServer.WINDOW_MODE_WINDOWED)

func set_screen_resolution(_screen_resolution):
	screen_resolution = _screen_resolution
	DisplayServer.call_deferred("window_set_mode", DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.call_deferred("window_set_size", screen_resolution)

func set_main_window(_main_window):
	main_window = _main_window
	DisplayServer.call_deferred("window_set_current_screen", main_window)

func set_vertical_sync(_vertical_sync):
	vertical_sync = _vertical_sync
	if vertical_sync:
		DisplayServer.call_deferred("window_set_vsync_mode", DisplayServer.VSYNC_ENABLED)
	else: 
		DisplayServer.call_deferred("window_set_vsync_mode", DisplayServer.VSYNC_DISABLED)

func set_frame_rate_limitation(_frame_rate_limitation):
	frame_rate_limitation = _frame_rate_limitation
	Engine.call_deferred("set_max_fps", frame_rate_limitation)

func set_ui_scaling(_ui_scaling):
	# Just used for save/load
	ui_scaling = _ui_scaling

func set_minimap(_minimap):
	# Just used for save/load
	minimap = _minimap

func set_shadow(_shadow):
	shadow = _shadow
	match shadow:
		0: # ULTRA
			RenderingServer.directional_shadow_atlas_set_size(16384, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
			GeneralSettings.current_world.light.shadow_bias = 0.005
			for viewport in viewports:
				viewport.positional_shadow_atlas_size = 16384
		1: # HIGH
			RenderingServer.directional_shadow_atlas_set_size(8192, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
			GeneralSettings.current_world.light.shadow_bias = 0.01
			for viewport in viewports:
				viewport.positional_shadow_atlas_size = 8192
		2: # MIDIUM
			RenderingServer.directional_shadow_atlas_set_size(4096, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
			GeneralSettings.current_world.light.shadow_bias = 0.02
			for viewport in viewports:
				viewport.positional_shadow_atlas_size = 4096
		3: # LOW
			RenderingServer.directional_shadow_atlas_set_size(2048, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
			GeneralSettings.current_world.light.shadow_bias = 0.03
			for viewport in viewports:
				viewport.positional_shadow_atlas_size = 2048
		4: # VERY LOW
			RenderingServer.directional_shadow_atlas_set_size(1024, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
			GeneralSettings.current_world.light.shadow_bias = 0.04
			for viewport in viewports:
				viewport.positional_shadow_atlas_size = 1024
		5: # DISABLED
			RenderingServer.directional_shadow_atlas_set_size(512, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
			GeneralSettings.current_world.light.shadow_bias = 0.06
			for viewport in viewports:
				viewport.positional_shadow_atlas_size = 0

func set_anti_alising(_anti_alising):
	anti_alising = _anti_alising
	match anti_alising:
		0: # MXAA_8
			for viewport in viewports:
				viewport.msaa_3d = Viewport.MSAA_8X
				viewport.use_taa = false
				viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		1: # MSAA_4
			for viewport in viewports:
				viewport.msaa_3d = Viewport.MSAA_4X
				viewport.use_taa = false
				viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		2: # MSAA_2
			for viewport in viewports:
				viewport.msaa_3d = Viewport.MSAA_2X
				viewport.use_taa = false
				viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		3: # TAA
			for viewport in viewports:
				viewport.use_taa = true
				viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		4: # FXAA
			for viewport in viewports:
				viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
				viewport.use_taa = false
		5: # DISABLED
			for viewport in viewports:
				viewport.msaa_3d = Viewport.MSAA_DISABLED
				viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED 

func set_ambient_occlusion(_ambient_occlusion):
	ambient_occlusion = _ambient_occlusion
	var world_environment:WorldEnvironment = GeneralSettings.current_world.world_environment
	match ambient_occlusion:
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

func set_texture(_texture):
	texture = _texture
	match texture:
		0: # ULTRA
			for viewport in viewports:
				viewport.mesh_lod_threshold = 0.0
		1: # HIGH
			for viewport in viewports:
				viewport.mesh_lod_threshold = 1.0
		2: # MEDIUM
			for viewport in viewports:
				viewport.mesh_lod_threshold = 2.0
		3: # LOW
			for viewport in viewports:
				viewport.mesh_lod_threshold = 4.0
		4: # VERY LOW
			for viewport in viewports:
				viewport.mesh_lod_threshold = 8.0
		5: # DISABLED
			for viewport in viewports:
				viewport.mesh_lod_threshold = 8.0 

func set_visual_effects(_visual_effects):
	visual_effects = _visual_effects
	var world_environment:WorldEnvironment = GeneralSettings.current_world.world_environment
	match visual_effects:
		0: # ULTRA
			world_environment.environment.set_ssr_enabled(true)
			world_environment.environment.set_ssr_max_steps(56)
			world_environment.environment.sdfgi_enabled = true
			world_environment.environment.glow_enabled = true
			# world_environment.environment.volumetric_fog_enabled = true
			RenderingServer.gi_set_use_half_resolution(false)
			RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_ULTRA, true, 0.5, 4, 50, 300)
			# RenderingServer.environment_set_volumetric_fog_filter_active(true)
			pass
		1: # HIGH
			world_environment.environment.set_ssr_enabled(true)
			world_environment.environment.set_ssr_max_steps(32)
			world_environment.environment.ssil_enabled = true
			world_environment.environment.sdfgi_enabled = true
			world_environment.environment.glow_enabled = true
			# world_environment.environment.volumetric_fog_enabled = true
			RenderingServer.gi_set_use_half_resolution(false)
			RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_HIGH, true, 0.5, 4, 50, 300)
			# RenderingServer.environment_set_volumetric_fog_filter_active(true)
			pass
		2: # MEDIUM
			world_environment.environment.set_ssr_enabled(true)
			world_environment.environment.set_ssr_max_steps(16)
			world_environment.environment.ssil_enabled = true
			world_environment.environment.sdfgi_enabled = true
			world_environment.environment.glow_enabled = true
			# world_environment.environment.volumetric_fog_enabled = true
			RenderingServer.gi_set_use_half_resolution(true)
			RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_MEDIUM, true, 0.5, 4, 50, 300)
			# RenderingServer.environment_set_volumetric_fog_filter_active(false)
			pass
		3: # LOW
			world_environment.environment.set_ssr_enabled(true)
			world_environment.environment.set_ssr_max_steps(8)
			world_environment.environment.ssil_enabled = true
			world_environment.environment.sdfgi_enabled = true
			world_environment.environment.glow_enabled = true
			# world_environment.environment.volumetric_fog_enabled = true
			RenderingServer.gi_set_use_half_resolution(true)
			RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_LOW, true, 0.5, 4, 50, 300)
			# RenderingServer.environment_set_volumetric_fog_filter_active(false)
			pass
		4: # VERY LOW
			world_environment.environment.set_ssr_enabled(true)
			world_environment.environment.set_ssr_max_steps(4)
			world_environment.environment.ssil_enabled = true
			world_environment.environment.sdfgi_enabled = false
			world_environment.environment.glow_enabled = false
			# world_environment.environment.volumetric_fog_enabled = false
			RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_VERY_LOW, true, 0.5, 4, 50, 300)
		5: # DISABLED
			world_environment.environment.set_ssr_enabled(false)
			world_environment.environment.ssil_enabled = false
			world_environment.environment.sdfgi_enabled = false
			world_environment.environment.glow_enabled = false
			# world_environment.environment.volumetric_fog_enabled = false
			pass
