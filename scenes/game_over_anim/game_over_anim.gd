extends Node2D
class_name GameOverAnimation

## If true, starts playing immediately.
@export var auto_play := true
@export var anim_duration := 5.0
@export var play_sound := true
## If true, when animation completes, go to game over. Otherwise, it deletes itself.
@export var go_to_game_over := true

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D
@onready var boom_1: AudioStreamPlayer = %Boom1
@onready var boom_2: AudioStreamPlayer = %Boom2
@onready var grr_sound: AudioStreamPlayer = %GrrSound
@onready var screen_fade: ColorRect = %ScreenFade
@onready var canvas_layer: CanvasLayer = %CanvasLayer

var game_over_reason: Enums.GameOverReason

func _ready() -> void:
	if auto_play:
		play()
	screen_fade.visible = go_to_game_over

func play() -> void:
	visible = true
	canvas_layer.visible = true
	animation_player.play("kaboom")
	gpu_particles_2d.emitting = true
	
	if play_sound:
		boom_1.play()
		boom_2.play()
		grr_sound.play()
	
	if go_to_game_over:
		_fade_out_audio()

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if go_to_game_over:
		SignalBus.emit_fade_out_screen()
		await SignalBus.fade_out_screen_complete
		SignalBus.emit_game_over(game_over_reason)
	queue_free()

func _fade_out_audio() -> void:
	SignalBus.emit_fade_out_bgm(anim_duration)
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(boom_1, "volume_linear", 0.0, anim_duration)
	tween.tween_property(boom_2, "volume_linear", 0.0, anim_duration)
	tween.tween_property(grr_sound, "volume_linear", 0.0, anim_duration)

func _on_boom_1_finished() -> void:
	boom_1.play()

func _on_boom_2_finished() -> void:
	boom_2.play()

func _on_grr_sound_finished() -> void:
	grr_sound.play()
