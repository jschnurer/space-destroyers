extends Node
class_name SpaceShooterLevelManager

@export var scroll_speed := 150.0
@export var scrolling_area_node: Node2D

func _process(delta: float) -> void:
	scrolling_area_node.global_position.y += scroll_speed * delta
