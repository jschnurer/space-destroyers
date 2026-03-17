extends Node
class_name LifeComponent

@export var life := 0.0

signal life_zeroed

## Takes damage. Returns remaining life.
func take_damage(damage: float) -> float:
	if life > 0:
		life -= damage
		if life <= 0.0:
			life = 0.0
			life_zeroed.emit()
	return life
