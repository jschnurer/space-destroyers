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
	
	var bullets := _bullet_pool.get_available_bullets(multi_level + 1)
	var num_bullets := bullets.size()
	
	if multi_level > 0:
		if num_bullets >= 1:
			_spawn_bullet(-8.0, 0.0, 0.55, Color.SILVER, bullets[0])
		if num_bullets >= 2:
			_spawn_bullet(8.0, 0.0, 0.55, Color.SILVER, bullets[1])
		if multi_level >= 2 and num_bullets >= 3:
			_spawn_bullet(-24, -4, 0.225, Color.GRAY, bullets[2])
		if multi_level >= 3 and num_bullets >= 4:
			_spawn_bullet(24, 4, 0.225, Color.GRAY, bullets[3])
	elif num_bullets >= 1:
		_spawn_bullet(0, 0, 1, Color.WHITE, bullets[0])
	
	# Play sound.
	SignalBus.emit_play_sfx(shot_sound)
	
	shot_fired.emit()
	
	# Start reloading.
	reload_component.reload()

func _spawn_bullet(bullet_offset: float, 
	angle_offset: float,
	damage_scale: float,
	bullet_modulate: Color,
	bullet: Bullet) -> void:
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
