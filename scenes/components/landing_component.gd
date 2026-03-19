extends Area2D

@export var game_over_anim_scene: PackedScene

func _on_area_entered(terrain: Area2D) -> void:
	_handle_collision(terrain)

func _on_body_entered(terrain: Node2D) -> void:
	_handle_collision(terrain)

func _handle_collision(terrain_node: Node2D) -> void:
	var terrain_shape: CollisionShape2D = Utilities.get_first_child_of_type(terrain_node, CollisionShape2D)
	var terrain_half_height := (terrain_shape.shape as RectangleShape2D).size.y / 2.0
	var my_shape: CollisionShape2D = Utilities.get_first_child_of_type(self, CollisionShape2D)
	var impact_point := Vector2(my_shape.global_position.x, terrain_shape.global_position.y - terrain_half_height)
	_spawn_explosion(impact_point)

func _spawn_explosion(point: Vector2) -> void:
	get_tree().paused = true
	var game_over_anim: GameOverAnimation = game_over_anim_scene.instantiate()
	game_over_anim.global_position = point
	game_over_anim.game_over_reason = Enums.GameOverReason.ENEMY_LANDED
	Utilities.add_child_to_level(game_over_anim)
