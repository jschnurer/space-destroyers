extends Area2D

@export var game_over_anim_scene: PackedScene

func _on_area_entered(terrain: Area2D) -> void:
	_handle_collision(terrain)

func _on_body_entered(terrain: Node2D) -> void:
	_handle_collision(terrain)

func _handle_collision(_terrain_node: Node2D) -> void:
	var my_shape: CollisionShape2D = Utilities.get_first_child_of_type(self, CollisionShape2D)
	var impact_point := Vector2(my_shape.global_position.x, Utilities.get_terrain_top_edge_y_position())
	_spawn_explosion(impact_point)

func _spawn_explosion(point: Vector2) -> void:
	PauseManager.pause()
	var game_over_anim: GameOverAnimation = game_over_anim_scene.instantiate()
	game_over_anim.global_position = point
	game_over_anim.game_over_reason = Enums.GameOverReason.ENEMY_LANDED
	Utilities.add_child_to_level(game_over_anim)
