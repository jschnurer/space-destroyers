extends Control
class_name MainMenu

@export var menu_bgm: AudioStream
@export var scroll_animation_duration := 4.0
@export var main_bgm: AudioStream
@export var invaders_levels: PackedScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var mission_update_text_animation: MissionUpdateTextAnimation = $MissionUpdateTextAnimation
@onready var start_game: Button = %"Start Game"
@onready var starfield: Node2D = %Starfield

func _ready() -> void:
	SignalBus.emit_fade_out_screen(true)
	SignalBus.emit_fade_in_screen()
	SignalBus.emit_toggle_mouse_visibility(true)
	SignalBus.emit_play_bgm(menu_bgm)
	start_game.grab_focus()

func _on_start_game_pressed() -> void:
	start_game.disabled = true
	SignalBus.emit_fade_out_bgm(1.0)
	animation_player.play("fade_out_ui")
	SignalBus.emit_toggle_mouse_visibility(false)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out_ui":
		mission_update_text_animation.visible = true
		mission_update_text_animation.play()

func _on_mission_update_text_animation_player_dismissed() -> void:
	get_tree().paused = true
	
	var tween := create_tween()
	var mission_update_text_animation_node: Control = mission_update_text_animation.get_child(0)
	tween.tween_property(mission_update_text_animation_node, "modulate:a", 0, 1)
	await tween.finished
	
	# Load next scene 3 screens below.
	var new_scene: Node2D = invaders_levels.instantiate()
	new_scene.global_position.y = 1080*3
	
	var gameplay_ui: CanvasLayer = new_scene.find_child("GameplayUI")
	
	# Load the main placeholder for levels to load into.
	get_tree().root.add_child(new_scene)

	# Load level 1.
	Game.load_initial_level()
	
	# Start some background music.
	SignalBus.emit_play_bgm(main_bgm as AudioStream, 1, 1, scroll_animation_duration / 2.0, scroll_animation_duration / 2.0)
	_scroll_screens(new_scene, gameplay_ui)

func _scroll_screens(new_scene: Node2D, gameplay_ui: CanvasLayer) -> void:
	var old_scene := get_tree().current_scene
	var tween := create_tween()
	
	# Hide the GameplayUI element.
	var gameplay_ui_node : Control = gameplay_ui.get_child(0)
	gameplay_ui_node.modulate.a = 0
	
	tween.set_parallel(true)
	# Stop scrolling the stars.
	tween.tween_property(starfield, "animate_speed", 0, scroll_animation_duration * .85)
	
	# Scroll both scenes upward.
	tween.tween_property(old_scene, "global_position:y", -1080*3, scroll_animation_duration) \
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(new_scene, "global_position:y", 0, scroll_animation_duration) \
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	
	tween.set_parallel(false)
	
	# Fade in the GameplayUI.
	tween.tween_property(gameplay_ui_node, "modulate:a", 1.0, 0.5)
	
	# Free the old scene and tell the engine that the loaded scene is now the current one.
	tween.tween_callback(func() -> void: 
		get_tree().current_scene = new_scene
		old_scene.queue_free()
		get_tree().paused = false
	)
