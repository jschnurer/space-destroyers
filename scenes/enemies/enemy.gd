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
		on_death.credit_value = credit_value
	
	var life_comp: LifeComponent = get_component(LifeComponent)
	if life_comp:
		life_comp.life = life

func apply_level_bonus() -> void:
	var difficulty_bonus := Game.game_state.current_difficulty
	credit_value *= (1 + (.5 * difficulty_bonus))
	life = floori(life * (1 + (.125 * difficulty_bonus)))
	
	# Apply size scale to life & credit value for larger enemies.
	if scale.x > 1:
		life = roundi((life + scale.x) * pow(scale.x, 1.225))
		credit_value = roundi((credit_value + scale.x) * pow(scale.x, 1.22))
	
	# Derive shield value from life.
	shield_life = floori(life * 12)
