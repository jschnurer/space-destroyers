extends Node2D
class_name PlayerOption

@export var player_shoot_comp: PlayerShootComponent
@export var projectile_scene: PackedScene

@onready var bullet_spawn_point: Node2D = $BulletSpawnPoint

func _ready() -> void:
	var player := get_tree().get_first_node_in_group(GroupNames.PLAYER)
	
	player_shoot_comp = Utilities.get_first_child_of_type(\
		player,\
		PlayerShootComponent
	)
	player_shoot_comp.shot_fired.connect(_on_player_shot_fired)

func _on_player_shot_fired() -> void:
	var projectile: BaseProjectile = projectile_scene.instantiate()
	projectile.global_position = bullet_spawn_point.global_position
	
	projectile.set_collision(1 << 3, 1 << 1)

	projectile.set_damage_speed_direction(\
		Game.get_stat_value(Enums.PlayerStats.DAMAGE),
		Game.get_stat_value(Enums.PlayerStats.SHOT_SPEED),
		Vector2.UP)
	
	Utilities.add_child_to_level(projectile, true)
