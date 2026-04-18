extends Node2D
class_name AutoShootComponent

## Reload component to stagger shots.
@export var reload_component: ReloadComponent
## The bullet scene to spawn.
@export var bullet_scene: PackedScene
## The name of the group to add the bullet to.
@export var bullet_group: String
## The color to modulate the bullet.
@export var shot_modulate: Color

@export_group("Behavior")
## The direction the shot will travel.
@export var shot_direction: Vector2
## The speed the shot will travel.
@export var shot_speed: float
## Damage dealt by the shot.
@export var shot_damage: float
## If true, shot_direction is ignored and the bullet will aim toward the player's current position.
@export var shoot_at_player := false

@export_group("Collision")
@export_flags_2d_physics var shot_collision_layer: int
@export_flags_2d_physics var shot_collision_mask: int

@export_group("Delay")
## If true, the first shot will be delayed by a random amount of time.
@export var delay_initial_shot := true
## Min delay before firing if delay_initial_shot is true.
@export_range(0.0, 60.0) var min_delay := 0.0
## Max delay before firing if delay_initial_shot is true.
@export_range(0.0, 60.0) var max_delay := 0.0

@export_group("Projectile Size")
## Overrides projectile scale (ignores inheritance if not 1.0).
@export var projectile_scale: float = 1.0
## If true, bullet scene will have same scale as provided sprite.
@export var inherit_sprite_scale: bool
## The sprite to inherit projectile scale from.
@export var inherit_from_sprite: Sprite2D

@onready var delay_timer: Timer = $DelayTimer

func _ready() -> void:
	reload_component.reload_complete.connect(_on_reload_complete)
	
	if delay_initial_shot:
		if min_delay > max_delay:
			printerr(self.name + ": Min delay is greater than max delay!")
			delay_timer.wait_time = min_delay
		else:
			delay_timer.wait_time = randf_range(min_delay, max_delay)
		delay_timer.start()
	else:
		call_deferred("shoot")

func _on_delay_timer_timeout() -> void:
	shoot()

func _on_reload_complete() -> void:
	shoot()

func shoot() -> void:
	_spawn_projectile(0.0)
	reload_component.reload()

func _spawn_projectile(position_offset: float) -> void:
	var projectile: BaseProjectile = bullet_scene.instantiate()
	projectile.global_position = global_position
	projectile.global_position.x += position_offset
	projectile.set_collision(shot_collision_layer, shot_collision_mask)
	projectile.set_power_speed_direction(\
		shot_damage,
		shot_speed,
		shot_direction)
	projectile.modulate = shot_modulate
	if bullet_group:
		projectile.add_to_group(bullet_group)
	
	if projectile_scale != 1.0:
		projectile.scale = Vector2.ONE * projectile_scale
	elif inherit_sprite_scale and inherit_from_sprite:
		projectile.scale = inherit_from_sprite.scale
	
	Utilities.call_deferred("add_child_to_level", projectile)
