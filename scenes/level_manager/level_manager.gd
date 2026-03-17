extends Node

@export var enemy_start_speed := 1.0
@export var enemy_max_speed := 5.0

var _enemy_count := 1
var _max_enemies := 1
var _enemy_speed := 1.0

func _ready() -> void:
	_enemy_speed = enemy_start_speed
	var enemies := get_tree().get_nodes_in_group(GroupNames.ENEMY)
	
	_enemy_count = enemies.size()
	_max_enemies = _enemy_count
	
	SignalBus.enemy_hit_screen_edge.connect(_on_enemy_hit_screen_edge)
	SignalBus.enemy_died.connect(_on_enemy_died)
	SignalBus.enemy_landed.connect(_on_enemy_landed)
	
	# Tell enemies their starting direction and speed
	SignalBus.emit_enemy_direction_change(Vector2.LEFT if randi_range(0, 1) == 1 else Vector2.RIGHT, false)
	SignalBus.emit_enemy_speed_change(_enemy_speed)

# TODO: Remove this debug stuff.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("nuke"):
		for en in get_tree().get_nodes_in_group(GroupNames.ENEMY):
			var lc := Utilities.get_first_child_of_type(en, LifeComponent)
			(lc as LifeComponent).take_damage(99999999.0)
	elif Input.is_action_just_pressed("pass_level"):
		for en in get_tree().get_nodes_in_group(GroupNames.ENEMY):
			en.queue_free()
		GameManager.load_next_level()

func _on_enemy_hit_screen_edge(edge: Enums.ScreenEdges) -> void:
	# Tell enemies to drop down and switch direction.
	SignalBus.emit_enemy_direction_change(Vector2.RIGHT if edge == Enums.ScreenEdges.LEFT else Vector2.LEFT, true)

func _on_enemy_died(_enemy: Node2D) -> void:
	# Subtract one enemy, calculate new enemy speed, and update all enemies' speeds.
	_enemy_count -= 1
	var pct := 1.0 - float(_enemy_count) / float(_max_enemies)
	_enemy_speed = lerp(enemy_start_speed, enemy_max_speed, pct)
	SignalBus.emit_enemy_speed_change(_enemy_speed)
	
	# All enemies slain. Start teleporting to next level!
	if _enemy_count == 0:
		SignalBus.emit_start_teleporting()

func _on_enemy_landed() -> void:
	print ("ENEMY LANDED!")
