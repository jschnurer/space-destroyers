extends Node2D
class_name GameOverAnimation

@export var anim_duration := 5.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var boom_1: AudioStreamPlayer = $Boom1
@onready var boom_2: AudioStreamPlayer = $Boom2
@onready var grr_sound: AudioStreamPlayer = $GrrSound

var game_over_reason: Enums.GameOverReason

func _ready() -> void:
	animation_player.play("kaboom")
	gpu_particles_2d.emitting = true
	_fade_out_audio()

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
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
