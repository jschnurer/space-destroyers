extends CharacterBody2D
class_name Spaceship

## The time it takes to fully rotate between directions.
@export var rotate_duration := 1.0
@export var shot_sound: AudioStream
@export var bullet_scene: PackedScene

@onready var smoke: GPUParticles2D = %Smoke
@onready var ship_sprite: Sprite2D = %ShipSprite
@onready var ship_mat: ShaderMaterial = (%ShipSprite as Sprite2D).material
@onready var fire: Sprite2D = %Fire
@onready var reload_component: ReloadComponent = $Components/ReloadComponent
@onready var bullet_spawn_point: Node2D = %BulletSpawnPoint

var _bank_speed := 2.5
var _max_bank := 0.7
var _lean_amount: float = 0.0
var _player_bounds: Rect2

func _ready() -> void:
	var sprite_size := ship_sprite.get_rect()
	var width := sprite_size.size.x
	var height := sprite_size.size.y
	_player_bounds = Rect2(width / 2.0, \
		Global.PLAYABLE_AREA_RECT.size.y * 0.33, \
		Global.PLAYABLE_AREA_RECT.size.x - width, \
		Global.PLAYABLE_AREA_RECT.size.y - height - Global.PLAYABLE_AREA_RECT.size.y * 0.33)
	_update_reload_time(Game.get_stat_value(Enums.PlayerStats.RELOAD))

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		_try_shoot()
	elif Game.has_upgrade(Enums.PlayerUpgrades.FULL_AUTO) and Input.is_action_pressed("shoot"):
		_try_shoot()
		
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
	#if Input.is_action_just_pressed("shoot"):
		#_try_shoot()
	#elif Game.has_upgrade(Enums.PlayerUpgrades.FULL_AUTO) and Input.is_action_pressed("shoot"):
		#_try_shoot()
		
	var speed := Game.get_stat_value(Enums.PlayerStats.TANK_SPEED)
	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	var target_velocity := input_dir * speed * delta * 100
	var buffer_y_top := 200.0
	var buffer_y_bottom := 100.0
	var buffer_x := 100.0

	if target_velocity.x < 0:
		var slowdown := remap(global_position.x, _player_bounds.position.x + buffer_x, _player_bounds.position.x, 1.0, 0.0)
		target_velocity.x *= clampf(slowdown, 0.0, 1.0)
	elif target_velocity.x > 0: 
		var slowdown := remap(global_position.x, _player_bounds.end.x - buffer_x, _player_bounds.end.x, 1.0, 0.0)
		target_velocity.x *= clampf(slowdown, 0.0, 1.0)

	if target_velocity.y < 0:
		var slowdown := remap(global_position.y, _player_bounds.position.y + buffer_y_top, _player_bounds.position.y, 1.0, 0.0)
		target_velocity.y *= clampf(slowdown, 0.0, 1.0)
	elif target_velocity.y > 0:
		var slowdown := remap(global_position.y, _player_bounds.end.y - buffer_y_bottom, _player_bounds.end.y, 1.0, 0.0)
		target_velocity.y *= clampf(slowdown, 0.0, 1.0)

	velocity = target_velocity
	move_and_slide()

func toggle_smoke_emission(emitting: bool) -> void:
	smoke.emitting = emitting

func _try_shoot() -> void:
	if reload_component.is_reloading():
		return
	
	# Shoot bullets.
	var multi_level := Game.get_upgrade_level(Enums.PlayerUpgrades.MULTI_CANNON)
	if multi_level > 0:
		_spawn_bullet(-8.0)
		_spawn_bullet(8.0)
		if multi_level >= 2:
			# Shoot one up left.
			_spawn_bullet(-16.0, -4, Vector2.ONE * 0.5)
		if multi_level >= 3:
			# Shoot one up right.
			_spawn_bullet(16, 4, Vector2.ONE * 0.5)
	else:
		_spawn_bullet(0)
	
	# Play sound.
	SignalBus.emit_play_sfx(shot_sound)
	
	# Start reloading.
	reload_component.reload()

func _spawn_bullet(bullet_offset: float, angle_offset: float = 0.0, bullet_scale: Vector2 = Vector2.ONE) -> void:
	var bullet: Bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_spawn_point.global_position
	bullet.global_position.x += bullet_offset
	bullet.set_collision(1 << 3, 1 << 1)
	
	var dir := Vector2.UP
	
	if angle_offset != 0.0:
		bullet.rotation = deg_to_rad(angle_offset)
		dir = Vector2.from_angle(deg_to_rad(-90 + angle_offset))
	
	bullet.scale *= bullet_scale
	
	bullet.set_power_speed_direction(\
		Game.get_stat_value(Enums.PlayerStats.DAMAGE),
		Game.get_stat_value(Enums.PlayerStats.SHOT_SPEED),
		dir)
	if Game.has_upgrade(Enums.PlayerUpgrades.FLAK_CANNON):
		bullet.can_flak = true
	
	Utilities.call_deferred("add_child_to_level", bullet)

func _update_reload_time(reload_time: float) -> void:
	reload_component.set_reload_time(reload_time)
