extends Node2D
class_name LuckyComponent

## The sprite to animate as lucky (gold).
@export var sprite: Sprite2D
## The duration of the lucky glint.
@export var lucky_glint_duration: float = .66
## If true, luck will be checked onready. Call roll_luck() to roll luck if this is false. Or call
## set_lucky(bool) to set it manually.
@export var auto_roll := true

signal lucky_changed(lucky: bool)

var is_lucky := false
var lucky_shader_mat := load("res://shaders/lucky_glint_shader_material.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if auto_roll:
		roll_luck()
	
	if is_lucky:
		var timer := get_timer()
		timer.wait_time = randf_range(0.0, 4.0)
		timer.call_deferred("start")

func _process(_delta: float) -> void:
	var sprite_mat := (sprite.material as ShaderMaterial)
	if not sprite_mat:
		return
	
	sprite_mat.set_shader_parameter("rotation", global_rotation)

func roll_luck() -> void:
	var luck := GameManager.get_player_stat_curr_value(Enums.PlayerStats.LUCK)
	set_lucky(randf_range(0.00, 100.0) <= luck)

func set_lucky(lucky: bool) -> void:
	is_lucky = lucky
	lucky_changed.emit(is_lucky)
	
	if lucky:
		sprite.material = lucky_shader_mat.duplicate()
		(sprite.material as ShaderMaterial).set_shader_parameter("hframes", float(sprite.hframes))
		(sprite.material as ShaderMaterial).set_shader_parameter("vframes", float(sprite.vframes))
		_set_lucky_shader_time(-1.0)

func _on_lucky_glint_timer_timeout() -> void:
	_play_lucky_glint()
	var timer := get_timer()
	timer.wait_time = lucky_glint_duration + randf_range(4.0, 7.0)
	timer.start()

func _play_lucky_glint() -> void:
	var tween := create_tween()
	tween.tween_method(_set_lucky_shader_time, 0.0, 2.0, lucky_glint_duration)
	tween.tween_callback(func() -> void: _set_lucky_shader_time(-1.0))

func _set_lucky_shader_time(value: float) -> void:
	(sprite.material as ShaderMaterial).set_shader_parameter("time", value)

func get_timer() -> Timer:
	return %LuckyGlintTimer as Timer
