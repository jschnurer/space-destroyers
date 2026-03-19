extends Node
class_name LifeComponent

@export var life := 0.0

signal life_zeroed

## Takes damage. Returns damage dealt.
func take_damage(damage: float) -> float:
	var damage_dealt := damage if life >= damage else life
	if life > 0:
		life -= damage
		if life <= 0.0:
			life = 0.0
			life_zeroed.emit()
			
	return damage_dealt
