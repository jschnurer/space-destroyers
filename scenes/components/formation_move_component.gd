extends Node
class_name FormationMoveComponent

## The node that will move around the screen.
@export var enemy_node: Node2D

var _direction := Vector2.LEFT
var _speed := 1.0

func _ready() -> void:
	SignalBus.enemy_direction_change.connect(_on_enemy_direction_change)
	SignalBus.enemy_speed_change.connect(_on_enemy_speed_change)

func _process(delta: float) -> void:
	if enemy_node:
		enemy_node.position += _direction * _speed * delta

func _drop_down_one_row() -> void:
	if enemy_node:
		enemy_node.position.y += Global.ENEMY_DROP_DISTANCE

func _on_enemy_direction_change(new_dir: Vector2, drop_down: bool) -> void:
	_direction = new_dir
	if drop_down:
		_drop_down_one_row()

func _on_enemy_speed_change(new_speed: float) -> void:
	_speed = new_speed
