extends Node2D
class_name FlakExplosion

## The bullet scene to spawn.
@export var bullet_scene: PackedScene
@export var life_time_component_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var flak_level := Game.get_upgrade_level(Enums.PlayerUpgrades.FLAK_CANNON)
	
	# If this scene was instantiated even though the player has no flak cannon, bail out.
	if flak_level == 0:
		return
	
	# Bullet damage is 10% the player's damage + 5% per flak level (max player damage)
	var player_dmg := Game.get_stat_value(Enums.PlayerStats.DAMAGE)
	var bullet_dmg := clampf((0.10 + flak_level * 0.05) * player_dmg, 0.001, player_dmg)
	
	# Spawn half the number of bullets as the cannon level (min 1, max 10) + 2.
	var num_bullets := clampi(ceili(flak_level / 2.0), 1, 10) + 2
	for i in range(num_bullets):
		_spawn_bullet(bullet_dmg)
	
	queue_free()

## Spawns a randomly-directed bullet from this location.
func _spawn_bullet(damage: float) -> void:
	# Determine random shot angle.
	var angle := randf_range(-PI, PI)
	
	var bullet: Bullet = bullet_scene.instantiate()
	bullet.rotation = angle + PI / 2.0
	bullet.global_position = global_position
	bullet.set_collision(1 << 3, 1 << 1)
	bullet.set_damage_speed_direction(\
		damage,
		1350.0,
		Vector2.from_angle(angle))
	bullet.can_flak = false
	
	# Must delete node after a moment.
	var life_time_comp := life_time_component_scene.instantiate() as LifetimeComponent
	life_time_comp.lifetime = 0.08
	life_time_comp.deletion_node = bullet
	bullet.add_child(life_time_comp)
	
	Utilities.call_deferred("add_child_to_level", bullet)
