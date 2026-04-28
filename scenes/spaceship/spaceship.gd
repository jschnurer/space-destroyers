extends CharacterBody2D
class_name Spaceship

@export var move_speed_multiplier := 50.0
## The time it takes to fully rotate between directions.
@export var rotate_duration := 1.0
@export var shot_sound: AudioStream
@export var bullet_scene: PackedScene

@onready var smoke: GPUParticles2D = %Smoke
@onready var ship_sprite: Sprite2D = %ShipSprite
@onready var ship_mat: ShaderMaterial = (%ShipSprite as Sprite2D).material
@onready var fire: Sprite2D = %Fire

var _bank_speed := 2.5
var _max_bank := 0.7
var _lean_amount: float = 0.0
var _player_move_bounds: Rect2

func _ready() -> void:
	var sprite_size := ship_sprite.get_rect()
	var width := sprite_size.size.x
	var height := sprite_size.size.y
	_player_move_bounds = Rect2(width / 2.0, \
		Global.PLAYABLE_AREA_RECT.size.y * 0.33, \
		Global.PLAYABLE_AREA_RECT.size.x - width, \
		Global.PLAYABLE_AREA_RECT.size.y - height - Global.PLAYABLE_AREA_RECT.size.y * 0.33)

func _process(delta: float) -> void:
	var move_x: float = Input.get_axis("move_left", "move_right")
	
	_lean_amount = lerp(_lean_amount, move_x, _bank_speed * delta)
	
	var squish := lerpf(1.0, _max_bank, absf(_lean_amount))
	ship_sprite.scale.x = squish
	fire.scale.x = squish
	
	var shadow_side := 0
	if _lean_amount < 0:
		shadow_side = -1
	elif _lean_amount > 0:
		shadow_side = 1
	
	ship_mat.set_shader_parameter("shadow_side", shadow_side)
	ship_mat.set_shader_parameter("shadow_intensity", absf(_lean_amount * 0.85))

func _physics_process(delta: float) -> void:
	var speed := Game.get_stat_value(Enums.PlayerStats.TANK_SPEED)
	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	var target_velocity := input_dir * speed * delta * move_speed_multiplier
	var buffer_y_top := 200.0
	var buffer_y_bottom := 100.0
	var buffer_x := 100.0

	if target_velocity.x < 0:
		var slowdown := remap(global_position.x, _player_move_bounds.position.x + buffer_x, _player_move_bounds.position.x, 1.0, 0.0)
		target_velocity.x *= clampf(slowdown, 0.0, 1.0)
	elif target_velocity.x > 0: 
		var slowdown := remap(global_position.x, _player_move_bounds.end.x - buffer_x, _player_move_bounds.end.x, 1.0, 0.0)
		target_velocity.x *= clampf(slowdown, 0.0, 1.0)

	if target_velocity.y < 0:
		var slowdown := remap(global_position.y, _player_move_bounds.position.y + buffer_y_top, _player_move_bounds.position.y, 1.0, 0.0)
		target_velocity.y *= clampf(slowdown, 0.0, 1.0)
	elif target_velocity.y > 0:
		var slowdown := remap(global_position.y, _player_move_bounds.end.y - buffer_y_bottom, _player_move_bounds.end.y, 1.0, 0.0)
		target_velocity.y *= clampf(slowdown, 0.0, 1.0)

	velocity = target_velocity
	move_and_slide()

func toggle_smoke_emission(emitting: bool) -> void:
	smoke.emitting = emitting
