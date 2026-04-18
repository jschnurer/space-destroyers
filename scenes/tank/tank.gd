extends CharacterBody2D
class_name Tank

@export var die_anim_scene: PackedScene

@onready var life_component: LifeComponent = $Components/LifeComponent
@onready var sprite_2d: Sprite2D = %Sprite2D

func _ready() -> void:
	life_component.life = Game.get_stat(Enums.PlayerStats.LIFE).get_current_value_int()
	life_component.life_changed.connect(_on_life_changed)
	Game.stat_changed.connect(_on_stat_changed)
	Game.current_life_changed.connect(_on_game_manager_current_life_changed)

func _physics_process(delta: float) -> void:
	velocity = Vector2(Input.get_axis("move_left", "move_right") \
		* Game.get_stat_value(Enums.PlayerStats.TANK_SPEED) \
		* delta, 0)
	
	move_and_collide(velocity)

func _on_stat_changed(stat: Stat) -> void:
	match stat.player_stat:
		Enums.PlayerStats.LIFE: life_component.life = stat.get_current_value_int()
	
func _on_life_changed(new_life: int, _hitbox: HitboxComponent) -> void:
	Game.set_current_life(new_life)

func _on_game_manager_current_life_changed(new_life: int) -> void:
	life_component.life = new_life

func _on_life_component_life_zeroed(_hitbox: HitboxComponent) -> void:
	get_tree().paused = true
	var die_anim: GameOverAnimation = die_anim_scene.instantiate()
	die_anim.global_position = sprite_2d.to_global(sprite_2d.get_rect().get_center())
	die_anim.game_over_reason = Enums.GameOverReason.TANK_DESTROYED
	Utilities.add_child_to_level(die_anim)

func get_scaled_sprite_rect() -> Rect2:
	var scaled_rect := Rect2(sprite_2d.get_rect())
	
	scaled_rect.size.x *= sprite_2d.scale.x
	scaled_rect.size.y *= sprite_2d.scale.y
	
	return scaled_rect
