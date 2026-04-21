extends Node2D
class_name BaseProjectile

@export var damage: float:
	set(value):
		damage = value
		if has_node("Components/HitboxComponent"):
			($Components/HitboxComponent as HitboxComponent).damage = value
var speed := 400.0
var direction := Vector2.UP

func _process(delta: float) -> void:
	position += direction * speed * delta

func set_damage_speed_direction(dmg: float, spd: float, dir: Vector2) -> void:
	damage = dmg
	speed = spd
	direction = dir

func set_collision(layer: int, mask: int) -> void:
	if has_node("Components/HitboxComponent"):
		($Components/HitboxComponent as HitboxComponent).collision_layer = layer
		($Components/HitboxComponent as HitboxComponent).collision_mask = mask
