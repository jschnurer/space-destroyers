extends Node
class_name PlayerLifeComponent

@export var die_anim_scene: PackedScene
@export var player_sprite: Sprite2D

@onready var life_component: LifeComponent = $LifeComponent

func _ready() -> void:
	life_component.life = Game.get_stat(Enums.PlayerStats.LIFE).get_current_value_int()
	Game.stat_changed.connect(_on_stat_changed)
	Game.current_life_changed.connect(_on_game_manager_current_life_changed)

func _on_stat_changed(stat: Stat) -> void:
	match stat.player_stat:
		Enums.PlayerStats.LIFE: life_component.life = stat.get_current_value_int()
	
func _on_game_manager_current_life_changed(new_life: int) -> void:
	life_component.life = new_life

func _on_life_component_life_zeroed(_hitbox: HitboxComponent) -> void:
	PauseManager.pause()
	var die_anim: GameOverAnimation = die_anim_scene.instantiate()
	die_anim.global_position = player_sprite.to_global(player_sprite.get_rect().get_center())
	die_anim.game_over_reason = Enums.GameOverReason.TANK_DESTROYED
	Utilities.add_child_to_level(die_anim)

func _on_life_component_life_changed(new_life: float, _hitbox: HitboxComponent) -> void:
	Game.set_current_life(ceili(new_life))
	print ("player life changed to %s" % new_life)
