extends Node2D

@export var delay_before_fade_out := 5.4

@export_group("Booster")
@export var booster_speed := 1200.0
@export var booster_time := 2.0

@export_group("Audio")
@export var klaxon_stream: AudioStream
@export var typewriter_stream: AudioStream
@export var jet_burst_stream: AudioStream
@export var open_doors_stream: AudioStream
@export var bgm: AudioStream

@onready var rocket: Node2D = %Rocket
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var smoke: GPUParticles2D = %Smoke
@onready var continue_prompt: Label = %ContinuePrompt
@onready var prompt_blink_timer: Timer = $PromptBlinkTimer
@onready var text_layer: CanvasLayer = $TextLayer
@onready var klaxon_player: AudioStreamPlayer2D = %KlaxonPlayer
@onready var mission_text: Label = %MissionText

enum LaunchMode {
	TITLE,
	TYPING,
	PROMPT,
	LAUNCHING,
	FADING,
}

var _rocket_velocity := Vector2.ZERO
var _mode := LaunchMode.TITLE
var _fade_delay_time := 0.0

func _ready() -> void:
	SignalBus.emit_play_bgm(bgm, 1.0, 1.0, 1.0, 1.0)
	animation_player.play("blink_mission_update")
	_play_audio(klaxon_stream)

func _process(delta: float) -> void:
	if _mode == LaunchMode.TITLE and Input.is_action_just_pressed("ui_accept"):
		animation_player.play("type_mission_text")
	elif _mode == LaunchMode.TYPING and Input.is_action_just_pressed("ui_accept"):
		animation_player.stop()
		mission_text.visible_ratio = 1.0
		_stop_audio()
		_show_continue_prompt()
	elif _mode == LaunchMode.PROMPT and Input.is_action_just_pressed("ui_accept"):
		text_layer.visible = false
		_mode = LaunchMode.LAUNCHING
		animation_player.play("open_doors")
		SignalBus.emit_play_sfx(open_doors_stream, .85, 0.05)
	elif _mode == LaunchMode.LAUNCHING:
		_fade_delay_time += delta
		rocket.global_position += _rocket_velocity * delta
		if rocket.global_position.y <= -200:
			smoke.emitting = false
		if _fade_delay_time >= delay_before_fade_out:
			_mode = LaunchMode.FADING
			SignalBus.emit_fade_out_bgm(1.0)
			SignalBus.emit_fade_out_screen()
			# TODO: Fade out screen, load new game mode, etc.

## Begins applying rocket velocity.
func _begin_moving_rocket() -> void:
	SignalBus.emit_play_sfx(jet_burst_stream, .85, 0.175)

	var velocity_tween := create_tween()
	
	velocity_tween\
		.tween_property(self, "_rocket_velocity", Vector2.UP * booster_speed, booster_time)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _show_continue_prompt() -> void:
	_mode = LaunchMode.PROMPT
	continue_prompt.visible = true
	prompt_blink_timer.start()

func _on_prompt_blink_timer_timeout() -> void:
	continue_prompt.visible = !continue_prompt.visible

func _play_typewriter_sound() -> void:
	_mode = LaunchMode.TYPING
	_play_audio(typewriter_stream)

func _play_audio(stream: AudioStream) -> void:
	klaxon_player.stop()
	klaxon_player.stream = stream
	klaxon_player.play()

func _on_klaxon_player_finished() -> void:
	klaxon_player.play()

func _stop_audio() -> void:
	klaxon_player.stop()
