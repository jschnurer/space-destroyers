extends Node2D
class_name PlayerPickupComponent

@onready var pickup_shape: CollisionShape2D = $PickupArea/PickupShape

func _ready() -> void:
	_update_pickup_area(Game.get_stat_value(Enums.PlayerStats.PICKUP_AREA))
	Game.stat_changed.connect(_on_stat_changed)

func _on_stat_changed(stat: Stat) -> void:
	match stat.player_stat:
		Enums.PlayerStats.PICKUP_AREA: _update_pickup_area(stat.get_current_value())

func _update_pickup_area(pickup_size: float) -> void:
	var shape := pickup_shape.shape as CircleShape2D
	if shape:
		shape.radius = pickup_size

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body is Credit:
		(body as Credit).start_pickup_sequence(self)
