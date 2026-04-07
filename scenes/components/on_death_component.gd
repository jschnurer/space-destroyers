extends Node2D
class_name OnDeathComponent

## Life component to listen for death.
@export var life_component: LifeComponent

@export_group("Sound")
## If true, plays sound on death.
@export var play_death_sound := true
## Sound to play on death.
@export var death_sound: AudioStream

@export_group("Enemy Death")
## If true, emits the enemy_died signal.
@export var emit_enemy_died := true
## Enemy node that will be emitted.
@export var enemy_node: Node2D

@export_group("Deletion")
## If true, deletion_node will be queue_free()'ed on death.
@export var deletion := true
## The node to queue_free when life zeroed.
@export var deletion_node: Node

@export_group("Credit Spawning")
@export var spawn_credit := true
## Scene of the credit to spawn on death.
@export var credit_scene: PackedScene
## How many credits is this enemy worth?
@export var credit_value := 1.0
## How many credits to spawn (applied AFTER lucky).
@export var credit_count_multiplier := 1.0
## (Optional) Lucky component to check if credit is lucky.
@export var lucky_component: LuckyComponent

@export_group("Death Animation")
@export var show_death_anim := true
## Scene to instantiate at this location to show death animation.
@export var death_anim_scene: PackedScene

@export_group("Flak Explosion")
@export var can_spawn_flak := false
var flak_scene: PackedScene = load("res://scenes/flak_explosion/flak_explosion.tscn")

func _ready() -> void:
	if life_component:
		life_component.life_zeroed.connect(_on_life_zeroed)

func _on_life_zeroed(hitbox: HitboxComponent) -> void:
	_try_play_death_sound()
	_try_spawn_credit()
	_try_death_anim()
	_try_enemy_death_emit()
	_try_spawn_flak(hitbox)
	_try_delete()

func _try_play_death_sound() -> void:
	if play_death_sound and death_sound:
		SignalBus.emit_play_sfx(death_sound, 0.8)

func _try_spawn_credit() -> void:
	if !spawn_credit:
		return
	
	var total_credit_value := get_total_credit_value()
	
	# Figure out how many and what value of credits to spawn.
	var pennies_to_spawn := 0
	var coins_to_spawn: Array[CreditDenomination] = []
	for i in range(Global.CREDIT_DENOMINATIONS.size() - 1, -1, -1):
		var denom := Global.CREDIT_DENOMINATIONS[i]
		var count := floori(total_credit_value / denom.value)
		if denom.value == 1.0:
			pennies_to_spawn += count
		else:
			for n in range(count):
				coins_to_spawn.append(denom)
		total_credit_value -= count * denom.value
		if total_credit_value == 0:
			break
	
	# Since the last fraction of a credit will be less than 1, spawn one additional coin worth
	# a whole credit.
	if total_credit_value > 0.0:
		pennies_to_spawn += 1
	
	if coins_to_spawn.size() > 0:
		# Now break down 10-25% of those to the next smaller size (min 1).
		var num_break_down := clampi(floori(randf_range(.1, .25) * coins_to_spawn.size()), 1, 100)
		for b in num_break_down:
			var ix := randi() % coins_to_spawn.size()
			var coin := coins_to_spawn[ix]
			
			# 20% chance of breaking down by 2 denominations, else only break by 1.
			var steps := -2 if (randf() < 0.2 and coin.array_index > 1) else -1
			# Find the denomination to break down to.
			var next_denom := Global.CREDIT_DENOMINATIONS[coin.array_index + steps]
			# And how many.
			var new_count := floori(coin.value / next_denom.value)
			
			# Remove this coin from the array.
			coins_to_spawn.remove_at(ix)
			
			# If the new denomination is a penny, just add its count.
			if next_denom.value == 1.0:
				pennies_to_spawn += new_count
			else:
				# Otherwise, add the new coins to the array.
				for i in new_count:
					coins_to_spawn.append(next_denom)
	
	for i in pennies_to_spawn:
		coins_to_spawn.append(Global.CREDIT_DENOMINATIONS[0])
	
	coins_to_spawn.shuffle()
	
	for i in coins_to_spawn:
		_spawn_credit(i)

## Simulates spawning credits and calculates their total value (without counting user stats).
func get_total_credit_value() -> float:
	if !spawn_credit:
		return 0.0
	
	var total_value := 0.0
	var num_credits := 1 if !lucky_component.is_lucky else randi_range(4, 6)
	num_credits = floor(num_credits * credit_count_multiplier)
	for i in range(num_credits):
		if lucky_component and lucky_component.is_lucky:
			total_value += (credit_value * randf_range(1.5, 2.75))
		else:
			total_value += credit_value
	return total_value

func _spawn_credit(credit_denomination: CreditDenomination) -> void:
	var credit := credit_scene.instantiate() as Credit
	credit.global_position = global_position + Vector2(randf_range(-1, 1), randf_range(-1, 1))
	credit.value = credit_denomination.value
	credit.denomination = credit_denomination
	Utilities.call_deferred("add_child_to_level", credit)

func _try_death_anim() -> void:
	if !show_death_anim or !death_anim_scene:
		return
	
	var death_anim := death_anim_scene.instantiate() as Node2D
	death_anim.global_position = global_position
	Utilities.call_deferred("add_child_to_level", death_anim)

func _try_enemy_death_emit() -> void:
	if emit_enemy_died and enemy_node:
		SignalBus.emit_enemy_died(enemy_node)

func _try_spawn_flak(hitbox: HitboxComponent) -> void:
	if !can_spawn_flak or !hitbox or !hitbox.can_flak:
		return
	
	var flak := flak_scene.instantiate() as FlakExplosion
	flak.global_position = global_position
	Utilities.call_deferred("add_child_to_level", flak)

func _try_delete() -> void:
	if deletion and deletion_node:
		deletion_node.queue_free()
