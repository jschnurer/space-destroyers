extends Node2D
class_name PlayerShootComponent

@export var bullet_scene: PackedScene
@export var shot_sound: AudioStream
@export var reload_component: PlayerReloadComponent
@export var bullet_pool_size := 100

signal shot_fired

var _can_shoot := true
var _bullet_pool: Array[Bullet] = []

func _ready() -> void:
	_init_bullet_pool()
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
	var bullet := _get_first_available_bullet()
	
	if !bullet:
		push_warning("No available bullet found in player bullet pool! (pool size: %s)" % bullet_pool_size)
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
	
	bullet.toggle_bullet(true)

## Initializes the bullet pool, creates the bullets, disables them.
func _init_bullet_pool() -> void:
	if !bullet_scene or bullet_pool_size <= 0:
		return
	
	_bullet_pool.resize(bullet_pool_size)
	
	var pool_node := get_tree().get_first_node_in_group(GroupNames.PLAYER_BULLET_POOL)
	
	for i in range(bullet_pool_size):
		var bullet: Bullet = bullet_scene.instantiate()
		
		# Add to player bullet group so it won't be deleted on impact.
		bullet.add_to_group(GroupNames.PLAYER_BULLET, true)
		
		# Set collision.
		bullet.set_collision(1 << 3, 1 << 1)
		
		# Don't want to delete when it leaves the screen! Remove the "delete offscreen" component.
		var comp := Utilities.get_first_child_of_type(bullet, DeleteOffscreenComponent)
		if comp:
			comp.free()
		
		# Add a trigger to detect when it leaves the screen to disable it.
		var vis := VisibleOnScreenNotifier2D.new()
		vis.rect = Rect2(-.5, -2, 1, 4)
		vis.screen_exited.connect(_on_bullet_screen_exited.bind(bullet))
		bullet.find_child("Components").add_child(vis)
		
		# Save it to the bullet pool.
		_bullet_pool[i] = bullet
		
		# Add to the scene.
		pool_node.add_child.call_deferred(bullet)
		
		# Disable and hide it.
		bullet.toggle_bullet(false)

## Triggered when a player bullet exits the screen.
func _on_bullet_screen_exited(bullet: Bullet) -> void:
	bullet.toggle_bullet(false)

## Finds the first available bullet that is in the pool and disabled so it can be used.
func _get_first_available_bullet() -> Bullet:
	for bullet in _bullet_pool:
		if bullet.process_mode == ProcessMode.PROCESS_MODE_DISABLED:
			return bullet
	return null
