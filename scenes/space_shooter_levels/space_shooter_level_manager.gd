extends Node
class_name SpaceShooterLevelManager

@export var scroll_speed := 150.0
@export var scrolling_area_node: Node2D

func _ready() -> void:
	## Find all enemies and disable them by default. They will turn on automatically when they
	## become visible.
	var enemies := get_tree().get_nodes_in_group(GroupNames.ENEMY)
	for enemy in enemies:
		enemy.process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta: float) -> void:
	scrolling_area_node.global_position.y += scroll_speed * delta
