extends Area2D
class_name IndependentMoveComponent

## The node that will move around the screen.
@export var moving_node: Node2D
## Initial move speed.
@export var initial_speed: float
## The percentage bonus to apply (to initial speed) each direction change.
@export var percent_speed_bonus_on_dir_change := 0.0

var _direction := Vector2.LEFT
var _speed := 1.0

func _ready() -> void:
	_speed = initial_speed

func _process(delta: float) -> void:
	if moving_node:
		moving_node.position += _direction * _speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area is not ScreenEdge:
		return
	
	var screen_edge := area as ScreenEdge
	
	# Change direction.
	_direction = Vector2.LEFT if screen_edge.edge == Enums.ScreenEdges.RIGHT\
		else Vector2.RIGHT
	
	# Drop down 1 row.
	if moving_node:
		moving_node.position.y += Global.ENEMY_DROP_DISTANCE
		if percent_speed_bonus_on_dir_change:
			_speed += initial_speed * percent_speed_bonus_on_dir_change
