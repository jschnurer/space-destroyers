extends Node
class_name LifeComponent

@export var life := 0.0

signal life_zeroed
signal life_changed(new_life: float)

## Takes damage. Returns damage dealt.
func take_damage(damage: float) -> float:
	var damage_dealt := damage if life >= damage else life
	if life > 0:
		life -= damage
		life_changed.emit(life)
		
		if life <= 0.0:
			life = 0.0
			life_zeroed.emit()
			
	return damage_dealt
