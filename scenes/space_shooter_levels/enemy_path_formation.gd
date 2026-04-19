extends Node2D
class_name EnemyPathFormation

## The list of enemies that will spawn and follow the path (in order).
@export var enemy_scenes: Array[SceneCount]
## The delay after spawning each enemy, before the next one spawns in.
@export var spawn_delay := 0.5
## The speed the enemies should follow the path.
@export var enemy_path_speed := 50.0
## If true, enemies rotate to follow path.
@export var rotate_enemies := false

@onready var path_2d: Path2D = %Path2D
@onready var spawn_timer: Timer = %SpawnTimer

var _spawn_index := 0
var _spawn_index_count := 0
var _lvl_manager: SpaceShooterLevelManager

func _ready() -> void:
	_lvl_manager = get_tree().get_first_node_in_group("LEVEL_MANAGER_SPACE") as SpaceShooterLevelManager
	spawn_timer.wait_time = spawn_delay
	spawn_timer.start()

func _process(delta: float) -> void:
	# Stop scrolling downward!
	position.y -= _lvl_manager.scroll_speed * delta
	
	for follower: PathFollow2D in path_2d.get_children():
		follower.progress += enemy_path_speed * delta
		if follower.progress_ratio >= 1.0:
			follower.queue_free()

func _on_spawn_timer_timeout() -> void:
	if _spawn_enemy():
		spawn_timer.start()

## Spawns the next enemy. Returns false when the last enemy is spawned.
func _spawn_enemy() -> bool:
	# Advance the spawn index/counter/etc. If false, no more enemies to spawn.
	if !_advance_spawn_counter():
		return false
	
	var follower := PathFollow2D.new()
	follower.loop = false
	follower.rotates = rotate_enemies
	
	var enemy: Node2D = enemy_scenes[_spawn_index].scene.instantiate()
	follower.add_child(enemy)
	path_2d.add_child(follower)
	
	_spawn_index_count += 1
	
	return true

func _advance_spawn_counter() -> bool:
	# Safety check.
	if _spawn_index > enemy_scenes.size() - 1:
		return false
	
	if _spawn_index_count > enemy_scenes[_spawn_index].count:
		# The last of this enemy type has already spawned. Advance.
		_spawn_index += 1
		_spawn_index_count = 0
		
		if _spawn_index > enemy_scenes.size() - 1:
			return false
	
	return true
