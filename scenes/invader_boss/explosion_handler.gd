extends Node2D
class_name ExplosionHandler

@export var invader_boss: InvaderBoss
@export var explosion_sound: AudioStream

@onready var boom_roar_sound: AudioStreamPlayer = %BoomRoarSound
@onready var boom_roar_sound_2: AudioStreamPlayer = %BoomRoarSound2
@onready var game_over_animation: GameOverAnimation = %GameOverAnimation
@onready var game_over_animation_2: GameOverAnimation = %GameOverAnimation2
@onready var game_over_animation_3: GameOverAnimation = %GameOverAnimation3
@onready var game_over_animation_4: GameOverAnimation = %GameOverAnimation4
@onready var game_over_animation_5: GameOverAnimation = %GameOverAnimation5
@onready var dance_component: DanceComponent = %DanceComponent
@onready var independent_move_component: IndependentMoveComponent = %IndependentMoveComponent

func play() -> void:
	PauseManager.pause()
	SignalBus.emit_flash_screen(Color.WHITE)
	SignalBus.emit_fade_out_bgm(3)
	
	# Destroy remaining disgorgers.
	var diss := invader_boss.disgorgers.get_children()
	for d: InvaderBossDisgorger in diss:
		d.toggle_destroyed(true)
	
	# Stop animating boss.
	dance_component.pause()
	# Stop moving boss.
	independent_move_component.queue_free()
	
	## Fade out the screen over 6.205 seconds (how long it takes for all anims to finish playing)
	SignalBus.emit_fade_out_screen(7.7, Color.WHITE)
	
	# Play constant sound.
	boom_roar_sound.volume_linear = 1.0
	boom_roar_sound.play()
	boom_roar_sound_2.volume_linear = 1.0
	boom_roar_sound_2.play()
	
	var sound_tween := create_tween()
	sound_tween.set_parallel(true)
	sound_tween.tween_property(boom_roar_sound, "volume_linear", 0.0, 8.5)
	sound_tween.tween_property(boom_roar_sound_2, "volume_linear", 0.0, 8.5)
	sound_tween.tween_property(boom_roar_sound, "pitch_scale", 0.05, 8.5)
	sound_tween.tween_property(boom_roar_sound_2, "pitch_scale", 0.05, 8.5)
	sound_tween.chain().tween_callback(func() -> void:
		boom_roar_sound.stop()
		boom_roar_sound_2.stop()
	)
	
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	tween.tween_callback(game_over_animation.play)
	tween.tween_callback(_play_explosion_sound)
	tween.tween_interval(1.25)
	tween.tween_callback(game_over_animation_2.play)
	tween.tween_callback(_play_explosion_sound)
	tween.tween_interval(0.5)
	tween.tween_callback(game_over_animation_3.play)
	tween.tween_callback(_play_explosion_sound)
	tween.tween_interval(0.75)
	tween.tween_callback(game_over_animation_4.play)
	tween.tween_callback(_play_explosion_sound)
	tween.tween_interval(.2)
	tween.tween_callback(game_over_animation_5.play)
	tween.tween_callback(_play_explosion_sound)
	tween.tween_interval(7)
	tween.tween_callback(func() -> void: invader_boss.emit_boss_killed())

func _play_explosion_sound() -> void:
	SignalBus.emit_play_sfx(explosion_sound, 1, 0.5)

func _on_boom_roar_sound_finished() -> void:
	boom_roar_sound.play()

func _on_boom_roar_sound_2_finished() -> void:
	boom_roar_sound_2.play()
