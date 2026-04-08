extends ColorRect
class_name TerrainBottom

func get_top_edge_global_y_position() -> float:
	var terrain_shape: CollisionShape2D = Utilities.get_first_child_of_type(self, CollisionShape2D)
	if terrain_shape:
		var terrain_half_height := (terrain_shape.shape as RectangleShape2D).size.y / 2.0
		return terrain_shape.global_position.y - terrain_half_height
	return -1000

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		(area as HitboxComponent).notify_dealt_damage(null, INF)
