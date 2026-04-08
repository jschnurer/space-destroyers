extends Node2D
class_name Enemy

@export var type: Enums.EnemyType
@export var enemy_sprite: Sprite2D
@export var life := 10:
	set(value):
		life = value
		var comp: LifeComponent = get_component(LifeComponent)
		if comp:
			comp.life = value
@export var shield_life := 50:
	set(value):
		shield_life = value
		var comp: ShieldComponent = get_component(ShieldComponent)
		if comp:
			comp.life = value
## Multiplier for how many credits to spawn on death.
@export var credit_count_multiplier := 1.0:
	set(value):
		credit_count_multiplier = value
		var on_death: OnDeathComponent = get_component(OnDeathComponent)
		if on_death:
			on_death.credit_count_multiplier = value
## Credit value.
@export var credit_value := 1.0:
	set(value):
		credit_value = value
		var on_death: OnDeathComponent = get_component(OnDeathComponent)
		if on_death:
			on_death.credit_value = value

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
