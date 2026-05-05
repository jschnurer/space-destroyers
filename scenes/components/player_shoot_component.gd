extends Node2D
class_name PlayerShootComponent

@export var bullet_scene: PackedScene
@export var shot_sound: AudioStream
@export var reload_component: PlayerReloadComponent

signal shot_fired

var _can_shoot := true
var _bullet_pool: PlayerBulletPool

func _ready() -> void:
	_bullet_pool = get_tree().get_first_node_in_group(GroupNames.PLAYER_BULLET_POOL)
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
		_spawn_bullet(-8.0, 0.0, 0.55, Color.SILVER)
		_spawn_bullet(8.0, 0.0, 0.55, Color.SILVER)
		if multi_level >= 2:
			_spawn_bullet(-24, -4, 0.225, Color.GRAY)
		if multi_level >= 3:
			_spawn_bullet(24, 4, 0.225, Color.GRAY)
	else:
		_spawn_bullet(0)
	
	# Play sound.
	SignalBus.emit_play_sfx(shot_sound)
	
	shot_fired.emit()
	
	# Start reloading.
	reload_component.reload()

func _spawn_bullet(bullet_offset: float, angle_offset: float = 0.0, damage_scale: float = 1.0, bullet_modulate: Color = Color.WHITE) -> void:
	var bullet := _bullet_pool.get_first_available_bullet()
	
	if !bullet:
		push_warning("No available bullet found in player bullet pool! (pool size: %s)" % _bullet_pool.bullet_pool_size)
		return
	
	bullet.global_position = global_position
	bullet.global_position.x += bullet_offset
	
	bullet.rotation = deg_to_rad(angle_offset)
	
	bullet.modulate = bullet_modulate
	
	bullet.set_damage_speed_direction(\
		Game.get_stat_value(Enums.PlayerStats.DAMAGE) * damage_scale,
		Game.get_stat_value(Enums.PlayerStats.SHOT_SPEED),
		Vector2.from_angle(deg_to_rad(-90 + angle_offset)))
	if Game.has_upgrade(Enums.PlayerUpgrades.FLAK_CANNON):
		bullet.can_flak = true
	
	# Enable the bullet.
	bullet.toggle_bullet(true)
