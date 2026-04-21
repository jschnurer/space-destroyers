extends Node2D
class_name PlayerShootComponent

@export var bullet_scene: PackedScene
@export var shot_sound: AudioStream
@export var reload_component: PlayerReloadComponent

signal shot_fired

var _can_shoot := true

func _ready() -> void:
	SignalBus.toggle_player_shoot_ability.connect(func(is_enabled: bool) -> void:
		_can_shoot = is_enabled
	)

func _process(_delta: float) -> void:
	if !_can_shoot:
		return

	if Input.is_action_just_pressed("shoot"):
		_try_shoot()
	elif Game.has_upgrade(Enums.PlayerUpgrades.FULL_AUTO) and Input.is_action_pressed("shoot"):
		_try_shoot()

func _try_shoot() -> void:
	if reload_component.is_reloading():
		return
	
	# Shoot bullets.
	var multi_level := Game.get_upgrade_level  (Enums.PlayerUpgrades.MULTI_CANNON)
	if multi_level > 0:
		_spawn_bullet(-8.0, 0.0, 1, 0.55)
		_spawn_bullet(8.0, 0.0, 1, 0.55)
		if multi_level >= 2:
			_spawn_bullet(-24, -4, 0.5, 0.225)
		if multi_level >= 3:
			_spawn_bullet(24, 4, 0.5, 0.225)
	else:
		_spawn_bullet(0)
	
	# Play sound.
	SignalBus.emit_play_sfx(shot_sound)
	
	shot_fired.emit()
	
	# Start reloading.
	reload_component.reload()

func _spawn_bullet(bullet_offset: float, angle_offset: float = 0.0, bullet_scale: float = 1.0, damage_scale: float = 1.0) -> void:
	var bullet: Bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.global_position.x += bullet_offset
	bullet.set_collision(1 << 3, 1 << 1)
	
	var dir := Vector2.UP
	
	if angle_offset != 0.0:
		bullet.rotation = deg_to_rad(angle_offset)
		dir = Vector2.from_angle(deg_to_rad(-90 + angle_offset))
	
	if bullet_scale != 1.0:
		bullet.scale_hitbox(bullet_scale)
		bullet.scale_sprite(bullet_scale)
	
	bullet.set_damage_speed_direction(\
		Game.get_stat_value(Enums.PlayerStats.DAMAGE) * damage_scale,
		Game.get_stat_value(Enums.PlayerStats.SHOT_SPEED),
		dir)
	if Game.has_upgrade(Enums.PlayerUpgrades.FLAK_CANNON):
		bullet.can_flak = true
		
	Utilities.call_deferred("add_child_to_level", bullet)
