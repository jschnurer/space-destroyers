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

func scale_sprite(p_scale: float) -> void:
	var sprite: Sprite2D = Utilities.get_first_child_of_type(self, Sprite2D)
	if !sprite:
		return
	
	sprite.scale = Vector2.ONE * p_scale

func scale_hitbox(p_scale: float) -> void:
	if has_node("Components/HitboxComponent"):
		var hb := ($Components/HitboxComponent as HitboxComponent)
		var collision_shape_2d: CollisionShape2D = hb.get_child(0)
		collision_shape_2d.shape = collision_shape_2d.shape.duplicate()
		var shape := collision_shape_2d.shape

		if shape is RectangleShape2D:
			(shape as RectangleShape2D).size *= p_scale
		elif shape is CircleShape2D:
			(shape as CircleShape2D).radius *= p_scale
		elif shape is CapsuleShape2D:
			(shape as CapsuleShape2D).radius *= p_scale
			(shape as CapsuleShape2D).height *= p_scale
