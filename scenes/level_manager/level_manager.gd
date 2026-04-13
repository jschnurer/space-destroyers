extends Node
class_name LevelManager

@export var enemy_start_speed := 1.0
@export var enemy_max_speed := 5.0

## Automatically start teleporting and then load next level when all enemies are destroyed.
@export var auto_load_next_level := true

signal all_enemies_destroyed

var _enemy_count := 1
var _max_enemies := 1
var _enemy_speed := 1.0

func _ready() -> void:
	_enemy_speed = enemy_start_speed
	var enemies := get_tree().get_nodes_in_group(GroupNames.ENEMY)
	
	_enemy_count = enemies.size()
	_max_enemies = _enemy_count
	
	# Add difficulty modifiers.
	var level_bonus := Game.game_state.current_level - 1
	for en in enemies:
		var e := en as Enemy
		e.credit_value *= (1 + (.10 * level_bonus))
		e.life = floori(e.life * (1 + (.125 * level_bonus)))
		
		# Apply size scale to life & credit value for larger enemies.
		if e.scale.x > 1:
			e.life = roundi((e.life + e.scale.x) * pow(e.scale.x, 1.225))
			e.credit_value = roundi((e.credit_value + e.scale.x) * pow(e.scale.x, 1.10))
		
		# Derive shield value from life.
		e.shield_life = floori(e.life * 6.5)
	
	SignalBus.enemy_hit_screen_edge.connect(_on_enemy_hit_screen_edge)
	SignalBus.enemy_died.connect(_on_enemy_died)
	
	# Tell enemies their starting direction and speed
	SignalBus.emit_enemy_direction_change(Vector2.LEFT if randi_range(0, 1) == 1 else Vector2.RIGHT, false)
	SignalBus.emit_enemy_speed_change(_enemy_speed)

func _on_enemy_hit_screen_edge(edge: Enums.ScreenEdges) -> void:
	# Tell enemies to drop down and switch direction.
	SignalBus.emit_enemy_direction_change(Vector2.RIGHT if edge == Enums.ScreenEdges.LEFT else Vector2.LEFT, true)

func _on_enemy_died(_enemy: Node2D) -> void:
	# Subtract one enemy, calculate new enemy speed, and update all enemies' speeds.
	_enemy_count -= 1
	
	if _enemy_count > 0:
		var pct := 1.0 - float(_enemy_count) / float(_max_enemies)
		_enemy_speed = lerp(enemy_start_speed, enemy_max_speed, pct)
		SignalBus.emit_enemy_speed_change(_enemy_speed)
	elif _enemy_count == 0:
		all_enemies_destroyed.emit()
		if auto_load_next_level:
			# All enemies slain. Start teleporting to next level!
			SignalBus.emit_start_teleporting()
