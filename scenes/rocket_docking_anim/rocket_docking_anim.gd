extends Node2D
class_name RocketDockingAnim

## If true, just skip entire animation.
@export var skip_play := false
## Duration of whole animation.
@export var dock_duration := 13.77
## Scroll speed of fastest stars as animation starts.
@export var max_star_speed := 100.0
## Final starfield scroll speed at anim conclusion.
@export var cruise_star_speed := 600.0
## Distance from wings for rocket fire to stop.
@export var rocket_cutoff_distance := 500.0
## Sound to play when docking (plays twice, low-high).
@export var dock_sound: AudioStream
## Sound of engine charging up.
@export var engine_charge_sound: AudioStream
## Starfield node to animate.
@export var starfield: Starfield
## Music to play during anim.
@export var bgm: AudioStream
## Music to play when bgm ends.
@export var level_bgm: AudioStream
## Sound of jet burst firing.
@export var jet_burst: AudioStream

@onready var empty_wings: Sprite2D = %EmptyWings
@onready var rocket: Rocket = %Rocket
@onready var anim_position: Node2D = %AnimPosition
@onready var rocket_sound_player: AudioStreamPlayer2D = $RocketSoundPlayer
@onready var spaceship: Spaceship = %Spaceship
@onready var air_jet_right: Polygon2D = %AirJetRight
@onready var air_jet_left: Polygon2D = %AirJetLeft

var _mode := Mode.FLYING_IN
var _fire_off := false
var _jets_activated := false
var _dock_sound_played := false

enum Mode {
	FLYING_IN,
	GLEAM,
}

func _ready() -> void:
	PauseManager.pause()
	SignalBus.emit_fade_in_screen()
	spaceship.toggle_smoke_emission(false)
	_animate_rocket_arriving()
	# Wait a frame then start the new bgm to override the GameManager's bgm.
	await get_tree().process_frame
	SignalBus.emit_play_bgm(bgm, 1.0, 1.0, 0.0, 2.0)

func _process(_delta: float) -> void:
	if rocket.position.y - empty_wings.position.y <= rocket_cutoff_distance and !_fire_off:
		rocket.toggle_fire(false)
		rocket.toggle_smoke_emission(false)
		_fire_off = true
		rocket_sound_player.stop()
	if rocket.position.y - empty_wings.position.y <= rocket_cutoff_distance * 0.75 and !_jets_activated:
		_animate_jets()
	if rocket.position.y <= 1.5 and !_dock_sound_played:
		_play_dock_sound()

func _animate_rocket_arriving() -> void:
	var tween := create_tween()
	
	tween.set_parallel(true)
	tween\
		.tween_property(rocket, "position", empty_wings.position, dock_duration)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween\
		.tween_property(anim_position, "position", Vector2(anim_position.position.x, 700), dock_duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	if starfield:
		tween\
			.tween_property(starfield, "animate_speed", max_star_speed, dock_duration / 2.0)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.set_parallel(false)
	tween.tween_callback(func() -> void: _animate_gleam())

func _animate_gleam() -> void:
	_mode = Mode.GLEAM
	empty_wings.visible = false
	rocket.visible = false
	spaceship.visible = true
	spaceship.toggle_smoke_emission(true)
	
	SignalBus.emit_flash_screen(Color.WHITE)
	
	SignalBus.emit_play_sfx(jet_burst)
	SignalBus.emit_play_bgm(level_bgm)
	PauseManager.resume()
	if skip_play:
		Engine.time_scale = 1.0
	
	if starfield:
		# Animate star speed!
		var tween := create_tween()
		tween\
			.tween_property(starfield, "animate_speed", cruise_star_speed, 2.5)\
			.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func _animate_jets() -> void:
	_jets_activated = true
	var tween := create_tween()
	
	tween.tween_callback(_air_jet_burst.bind(true, false))
	tween.tween_interval(0.3)
	tween.tween_callback(_air_jet_burst.bind(false, true, false))
	tween.tween_interval(0.2)
	tween.tween_callback(_air_jet_burst.bind(false, true, false))
	tween.tween_interval(0.1)
	tween.tween_callback(_air_jet_burst.bind(true, false))
	tween.tween_interval(0.2)
	tween.tween_callback(_air_jet_burst.bind(true, false))
	tween.tween_interval(0.2)
	tween.tween_callback(_air_jet_burst.bind(true, false))
	tween.tween_interval(0.2)
	tween.tween_callback(_air_jet_burst.bind(true, true, 1.25))
	tween.tween_interval(0.5)
	tween.tween_callback(_air_jet_burst.bind(true, false))
	tween.tween_interval(0.1)
	tween.tween_callback(_air_jet_burst.bind(false, true))
	tween.tween_interval(0.2)
	tween.tween_callback(_air_jet_burst.bind(true, false))
	tween.tween_interval(1)
	tween.tween_callback(_air_jet_burst.bind(true, true, 1.25))

func _air_jet_burst(show_left: bool, show_right: bool, duration: float = 0.1) -> void:
	if show_left:
		_flash_burst(air_jet_left, duration)
	if show_right:
		_flash_burst(air_jet_right, duration)

func _flash_burst(burst: Polygon2D, duration: float) -> void:
	burst.visible = true
	await get_tree().create_timer(duration).timeout
	burst.visible = false

func _play_dock_sound() -> void:
	_dock_sound_played = true
	
	SignalBus.emit_play_sfx(dock_sound, 1, 0.075)
	await get_tree().create_timer(0.2).timeout
	SignalBus.emit_play_sfx(dock_sound, 1, 0.2)
	SignalBus.emit_play_sfx(engine_charge_sound, 1, 1.75)
