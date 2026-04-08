extends Control
class_name MainMenu

@export var bgm: AudioStream

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var mission_update_text_animation: MissionUpdateTextAnimation = $MissionUpdateTextAnimation
@onready var start_game: Button = %"Start Game"

func _ready() -> void:
	SignalBus.emit_toggle_mouse_visibility(true)
	SignalBus.emit_play_bgm(bgm)
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
	SignalBus.emit_fade_out_bgm(1.0)
	SignalBus.emit_fade_out_screen()
	await SignalBus.fade_out_screen_complete
	GameManager.switch_to_scene_file("res://scenes/invaders_levels.tscn")
