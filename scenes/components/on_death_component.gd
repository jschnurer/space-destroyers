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
## (Optional) Lucky component to check if credit is lucky.
@export var lucky_component: LuckyComponent

@export_group("Death Animation")
@export var show_death_anim := true
## Scene to instantiate at this location to show death animation.
@export var death_anim_scene: PackedScene

func _ready() -> void:
	if life_component:
		life_component.life_zeroed.connect(_on_life_zeroed)

func _on_life_zeroed() -> void:
	_try_play_death_sound()
	_try_spawn_credit()
	_try_death_anim()
	_try_enemy_death_emit()
	_try_delete()

func _try_play_death_sound() -> void:
	if play_death_sound and death_sound:
		SignalBus.emit_play_sfx(death_sound, 0.8)

func _try_spawn_credit() -> void:
	if !spawn_credit:
		return
	
	var num_credits := 1 if !lucky_component.is_lucky else randi_range(3, 5)

	var creds: Array[Node] = []

	for i in range(num_credits):
		var credit := credit_scene.instantiate() as Credit
		credit.global_position = global_position
		if lucky_component and lucky_component.is_lucky:
			credit.value = credit_value * randf_range(2.0, 3.0)
		credit.set_lucky(lucky_component.is_lucky)
		creds.append(credit)
	
	Utilities.call_deferred("add_children_to_level", creds)

func _try_death_anim() -> void:
	if !show_death_anim or !death_anim_scene:
		return
	
	var death_anim := death_anim_scene.instantiate() as Node2D
	death_anim.global_position = global_position
	Utilities.call_deferred("add_child_to_level", death_anim)

func _try_enemy_death_emit() -> void:
	if emit_enemy_died and enemy_node:
		SignalBus.emit_enemy_died(enemy_node)

func _try_delete() -> void:
	if deletion and deletion_node:
		deletion_node.queue_free()
