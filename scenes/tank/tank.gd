extends CharacterBody2D

## The bullet to spawn when shooting.
@export var bullet_scene: PackedScene
@export var shot_sound: AudioStream

@onready var bullet_spawn_point: Node2D = $BulletSpawnPoint
@onready var reload_component: ReloadComponent = %ReloadComponent
@onready var pickup_shape: CollisionShape2D = $PickupArea/PickupShape
@onready var pickup_point: Node2D = $PickupPoint

var _active_bullet_count := 0

func _ready() -> void:
	_update_reload_time(GameManager.get_player_stat(Enums.PlayerStats.RELOAD))
	_update_pickup_area(GameManager.get_player_stat(Enums.PlayerStats.PICKUP_AREA))
	GameManager.player_stat_changed.connect(_player_stat_changed)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		_try_shoot()
	elif GameManager.has_upgrade(Enums.PlayerUpgrades.AUTO_FIRE) and Input.is_action_pressed("shoot"):
		_try_shoot()
		
	velocity = Vector2(Input.get_axis("move_left", "move_right") \
		* GameManager.get_player_stat_curr_value(Enums.PlayerStats.TANK_SPEED) \
		* delta, 0)
	
	move_and_collide(velocity)

func _try_shoot() -> void:
	if reload_component.is_reloading():
		return
	
	if _active_bullet_count >= GameManager.get_player_stat_curr_value(Enums.PlayerStats.MAX_SHOTS):
		return
	
	# Shoot bullets.
	if GameManager.has_upgrade(Enums.PlayerUpgrades.TWIN_CANNON):
		_spawn_bullet(-8.0)
		_spawn_bullet(8.0)
	else:
		_spawn_bullet(0)
	
	# Play sound.
	SignalBus.emit_play_sfx(shot_sound)
	
	# Start reloading.
	reload_component.reload()

func _on_bullet_died() -> void:
	# Subtract one from the active bullet count (min 0).
	_active_bullet_count = clampi(_active_bullet_count - 1, 0, 999999)

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body is Credit:
		(body as Credit).start_pickup_sequence(pickup_point)

func _player_stat_changed(stat: Enums.PlayerStats, value: PlayerStat) -> void:
	match stat:
		Enums.PlayerStats.RELOAD: _update_reload_time(value)
		Enums.PlayerStats.PICKUP_AREA: _update_pickup_area(value)

func _update_reload_time(reload_value: PlayerStat) -> void:
	reload_component.set_reload_time(reload_value.base_value / (1.0 + reload_value.percent_modifier))

func _update_pickup_area(stat: PlayerStat) -> void:
	var shape := pickup_shape.shape as CircleShape2D
	if shape:
		shape.radius = stat.current_value

func _spawn_bullet(bullet_offset: float) -> void:
	var bullet: Bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_spawn_point.global_position
	bullet.global_position.x += bullet_offset
	bullet.collision_layer = 1 << 3
	bullet.collision_mask = 1 << 1
	var speed_value := GameManager.get_player_stat(Enums.PlayerStats.SHOT_SPEED)
	bullet.set_power_speed_direction(\
		GameManager.get_player_stat_curr_value(Enums.PlayerStats.SHOT_POWER),
		1000.0 - speed_value.base_value / (1.0 + speed_value.percent_modifier),
		Vector2.UP)
	bullet.tree_exited.connect(_on_bullet_died)
	Utilities.call_deferred("add_child_to_level", bullet)
	_active_bullet_count += 1
