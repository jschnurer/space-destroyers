extends CharacterBody2D
class_name Tank

@export var die_anim_scene: PackedScene

@onready var sprite_2d: Sprite2D = %Sprite2D

func _physics_process(delta: float) -> void:
	velocity = Vector2(Input.get_axis("move_left", "move_right") \
		* Game.get_stat_value(Enums.PlayerStats.TANK_SPEED) \
		* delta, 0)
	
	move_and_collide(velocity)

func get_scaled_sprite_rect() -> Rect2:
	var scaled_rect := Rect2(sprite_2d.get_rect())
	
	scaled_rect.size.x *= sprite_2d.scale.x
	scaled_rect.size.y *= sprite_2d.scale.y
	
	return scaled_rect
