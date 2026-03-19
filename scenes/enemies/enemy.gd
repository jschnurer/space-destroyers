extends Node2D
class_name Enemy

@export var type: Enums.EnemyType
@export var enemy_sprite: Sprite2D
@export var life := 10
## Multiplier for how many credits to spawn on death.
@export var credit_count_multiplier := 1.0
## Credit value.
@export var credit_value := 1.0

func get_component(p_type: Variant) -> Variant:
	return Utilities.get_first_child_of_type(self, p_type)

func _ready() -> void:
	var on_death: OnDeathComponent = get_component(OnDeathComponent)
	if on_death:
		on_death.credit_count_multiplier = credit_count_multiplier
		on_death.credit_value = credit_value
	
	var life_comp: LifeComponent = get_component(LifeComponent)
	if life_comp:
		life_comp.life = life
