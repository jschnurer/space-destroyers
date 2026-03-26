extends ColorRect
class_name TerrainBottom

var _top_edge_global_y_position: float = 0.0

func _ready() -> void:
	var terrain_shape: CollisionShape2D = Utilities.get_first_child_of_type(self, CollisionShape2D)
	if terrain_shape:
		var terrain_half_height := (terrain_shape.shape as RectangleShape2D).size.y / 2.0
		_top_edge_global_y_position = terrain_shape.global_position.y - terrain_half_height

func get_top_edge_global_y_position() -> float:
	return _top_edge_global_y_position

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		(area as HitboxComponent).notify_dealt_damage(null, INF)
