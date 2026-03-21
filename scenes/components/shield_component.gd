@tool
extends Sprite2D
class_name ShieldComponent

@export var life: float

@export_group("Shield Visibility")
@export var invisible: bool = true
@export var show_on_hit: bool = true
@export var visible_duration: float = 0.06

@export_group("Collision")
@export_flags_2d_physics var collision_layer: int
@export_flags_2d_physics var collision_mask: int

var _rehide_time := 0.0

func _ready() -> void:
	($Components/LifeComponent as LifeComponent).life = life
	($Components/HurtboxComponent as HurtboxComponent).collision_layer = collision_layer
	($Components/HurtboxComponent as HurtboxComponent).collision_mask = collision_mask
	
	if invisible:
		visible = false

func _process(delta: float) -> void:
	if show_on_hit and _rehide_time > 0:
		_rehide_time -= delta
		if _rehide_time <= 0:
			_rehide_time = 0
			visible = false

func _on_hurtbox_component_on_hurtbox_hit(_hitbox: HitboxComponent) -> void:
	if show_on_hit:
		visible = true
		_rehide_time = visible_duration
