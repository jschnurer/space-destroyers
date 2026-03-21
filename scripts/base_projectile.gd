extends Node2D
class_name BaseProjectile

@export var damage: float:
	set(value):
		damage = value
		if has_node("Components/HitboxComponent"):
			($Components/HitboxComponent as HitboxComponent).damage = value

@export_flags_2d_physics var collision_layer: int:
	set(value):
		if has_node("Components/HitboxComponent"):
			($Components/HitboxComponent as HitboxComponent).collision_layer = value
	get():
		if has_node("Components/HitboxComponent"):
			return ($Components/HitboxComponent as HitboxComponent).collision_layer
		return 0
@export_flags_2d_physics var collision_mask: int:
	set(value):
		if has_node("Components/HitboxComponent"):
			($Components/HitboxComponent as HitboxComponent).collision_mask = value
	get():
		if has_node("Components/HitboxComponent"):
			return ($Components/HitboxComponent as HitboxComponent).collision_mask
		return 0

var speed := 400.0
var power: float:
	set(value):
		power = value
		if has_node("Components/HitboxComponent"):
			($Components/HitboxComponent as HitboxComponent).damage = value
var direction := Vector2.UP

func _process(delta: float) -> void:
	position += direction * speed * delta

func set_power_speed_direction(pwr: float, spd: float, dir: Vector2) -> void:
	power = pwr
	speed = spd
	direction = dir
