extends Node2D
class_name RocketLaunchAnimation

## Delay after launching rocket before fading out screen.
@export var delay_before_fade_out := 5.4
## Play as soon as ready?
@export var autoplay := false

@export_group("Booster")
@export var booster_speed := 1200.0
@export var booster_time := 2.0

@export_group("Audio")
@export var jet_burst_stream: AudioStream
@export var open_doors_stream: AudioStream

@onready var rocket: Rocket = %Rocket
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var mission_update_text_animation: MissionUpdateTextAnimation = %MissionUpdateTextAnimation

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
	mission_update_text_animation.player_dismissed.connect(_on_mission_update_text_done)
	
	if autoplay:
		play()

## Begins playing mission text then animation.
func play() -> void:
	reposition()
	PauseManager.pause()
	
	mission_update_text_animation.play()

## Aligns animation with player.
func reposition() -> void:
	var player_tank: Tank = get_tree().get_first_node_in_group("PLAYER")
	global_position = player_tank.global_position
	player_tank.visible = false

func _on_mission_update_text_done() -> void:
	mission_update_text_animation.queue_free()
	_mode = LaunchMode.LAUNCHING
	animation_player.play("open_doors")
	SignalBus.emit_play_sfx(open_doors_stream, 0.85, 0.05)

func _process(delta: float) -> void:
	if _mode == LaunchMode.LAUNCHING:
		_fade_delay_time += delta
		rocket.global_position += _rocket_velocity * delta
		if rocket.global_position.y <= -200:
			rocket.toggle_smoke_emission(false)
		if _fade_delay_time >= delay_before_fade_out:
			_fade_out()

## Begins applying rocket velocity.
func _begin_moving_rocket() -> void:
	SignalBus.emit_play_sfx(jet_burst_stream, .85, 0.175)

	var velocity_tween := create_tween()
	
	velocity_tween\
		.tween_property(self, "_rocket_velocity", Vector2.UP * booster_speed, booster_time)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _fade_out() -> void:
	_mode = LaunchMode.FADING
	SignalBus.emit_fade_out_bgm(1.0)
	SignalBus.emit_fade_out_screen()
	await SignalBus.fade_out_screen_complete
	SignalBus.emit_open_shop()
	await SignalBus.shop_closed
	get_tree().change_scene_to_file("res://scenes/space_shooter_levels/space_shooter_levels.tscn")
	# TODO: Open shop, set game mode to vert scroller.
