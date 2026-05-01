@tool
extends Node2D
class_name EnemyPathFormation

## The list of enemies that will spawn and follow the path (in order).
@export var enemy_scenes: Array[SceneCount]
## Level Manager (to get scroll speed and update editor display).
@export var level_manager: SpaceShooterLevelManager
## Total time it takes to spawn all enemies.
@export var spawn_duration: float = 5.0
## The speed the enemies should follow the path.
@export var enemy_path_speed := 50.0
## If true, enemies rotate to follow path.
@export var rotate_enemies := false
## The PathFollower scene.
@export var path_follower_scene: PackedScene

@export_group("Editor Hints")
## Show a meter upward for total time for spawns followed by the time for the last enemy to reach
## the end of the path.
@export var editor_show_time_hint: bool = true:
	set(value):
		editor_show_time_hint = value
		queue_redraw()

@onready var spawn_timer: Timer = %SpawnTimer

var _spawn_index := 0
var _spawn_index_count := 0
var _enemy_path: Path2D

func _ready() -> void:
	if !Engine.is_editor_hint():
		_find_path()
	
	_update_timer()
	
	if !Engine.is_editor_hint() and _enemy_path:
		# Spawn the first enemy immediately, then use the timer to wait between each.
		_on_spawn_timer_timeout()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or !_enemy_path:
		return
	
	# Stop scrolling downward!
	position.y -= level_manager.scroll_speed * delta
	
	for follower: PathFollow2D in _enemy_path.get_children():
		follower.progress += enemy_path_speed * delta
		if follower.progress_ratio >= 1.0:
			follower.queue_free()

func _draw() -> void:
	if !editor_show_time_hint:
		return
	
	if Engine.is_editor_hint() and level_manager:
		var height := spawn_duration * level_manager.scroll_speed
		var fill_color := Color.RED
		fill_color.a = 0.5
		draw_rect(Rect2(Vector2(-20, -height), Vector2(40, height)), fill_color)
		
		var path: Path2D
		for child in find_children("*", "Path2D", true):
			path = child as Path2D
		
		if path:
			var length := path.curve.get_baked_length()
			var move_time_height := (length / enemy_path_speed) * level_manager.scroll_speed
			var path_time_fill_color := Color.YELLOW
			path_time_fill_color.a = 0.5
			draw_rect(Rect2(Vector2(-20, -move_time_height - height), Vector2(40, move_time_height)), path_time_fill_color)

func _get_enemy_spawn_count_total() -> int:
	var en_count := 0
	for g in enemy_scenes:
		en_count += g.count
	return en_count

func _update_timer() -> void:
	var en_count := _get_enemy_spawn_count_total()
		
	if en_count == 0:
		return
		
	(%SpawnTimer as Timer).wait_time = spawn_duration / (en_count - 1)

func _on_spawn_timer_timeout() -> void:
	call_deferred("_spawn_enemy")

## Spawns the next enemy. Returns false when the last enemy is spawned.
func _spawn_enemy() -> void:
	# Advance the spawn index/counter/etc. If false, no more enemies to spawn.
	if !_advance_spawn_counter():
		return
	
	var follower := path_follower_scene.instantiate() as PathFollow2D
	follower.loop = false
	follower.rotates = rotate_enemies
	
	var enemy: Node2D = enemy_scenes[_spawn_index].scene.instantiate()
	Utilities.add_child_to_level(enemy)
	
	var transformer: RemoteTransform2D = Utilities.get_first_child_of_type(follower, RemoteTransform2D)
	transformer.remote_path = enemy.get_path()
	
	_enemy_path.add_child(follower)
	
	_spawn_index_count += 1
	
	spawn_timer.start()

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

func _find_path() -> void:
	var first_path := Utilities.get_first_child_of_type(self, Path2D)
	if first_path == null:
		printerr(self.name + " has no child Path2D!")
		queue_free()
	else:
		_enemy_path = first_path
