extends Node2D
class_name PlayerOption

@export var player_shoot_comp: PlayerShootComponent

@onready var bullet_spawn_point: Node2D = $BulletSpawnPoint

var power_bonus := 0

func _ready() -> void:
	var player := get_tree().get_first_node_in_group(GroupNames.PLAYER)
	
	player_shoot_comp = Utilities.get_first_child_of_type(\
		player,\
		PlayerShootComponent
	)
	player_shoot_comp.shot_fired.connect(_on_player_shot_fired)

func _on_player_shot_fired() -> void:
	var bullets := player_shoot_comp._bullet_pool.get_available_bullets(1)
	
	var bullet: Bullet
	
	if bullets.size() == 0:
		return

	bullet = bullets[0]

	bullet.global_position = bullet_spawn_point.global_position
	
	bullet.set_collision(1 << 3, 1 << 1)

	bullet.set_damage_speed_direction(\
		Game.get_stat_value(Enums.PlayerStats.DAMAGE) * (0.20 + power_bonus * 0.15),
		Game.get_stat_value(Enums.PlayerStats.SHOT_SPEED),
		Vector2.UP)
	
	bullet.toggle_bullet(true)

# Resets position
func reset() -> void:
	pass
