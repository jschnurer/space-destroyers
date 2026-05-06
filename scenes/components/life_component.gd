extends Node
class_name LifeComponent

@export var life := 0.0
## If true, even 0 damage will show the damage flash.
@export var always_flash_damage := false

var god_mode := false

signal life_zeroed(hitbox: HitboxComponent)
signal life_changed(new_life: float, hitbox: HitboxComponent)

## Takes damage. Returns damage dealt.
func take_damage(damage: float, hitbox: HitboxComponent) -> float:
	var damage_dealt := clampf(damage, 0, life)
	
	if god_mode:
		damage_dealt = 0
	
	if life > 0:
		life -= damage_dealt
		life_changed.emit(life, hitbox)
		
		if life <= 0:
			life = 0
			life_zeroed.emit(hitbox)
			
	return damage_dealt
