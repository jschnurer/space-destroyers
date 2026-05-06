extends CanvasLayer
class_name GameplayUI

@onready var current_life: Label = %CurrentLife
@onready var credits_display: Label = %CreditsDisplay
@onready var controls_container: HBoxContainer = %ControlsContainer
@onready var life_container: HBoxContainer = %LifeContainer
@onready var credits_container: HBoxContainer = %CreditsContainer

@onready var life_area_shape: CollisionShape2D = %LifeAreaShape
@onready var credits_area_shape: CollisionShape2D = %CreditsAreaShape

var _inputs_that_clear_instructions: Array[String] = ["move_left", "move_right", "shoot"]
var _clear_instructions_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.credits_changed.connect(_on_credits_changed)
	Game.current_life_changed.connect(_on_current_life_changed)
	_on_current_life_changed(Game.game_state.current_life)
	_on_credits_changed(Game.game_state.credits)
	
	life_area_shape.disabled = Game.game_state.current_level_type == Enums.LevelTypes.INVADERS

func _on_credits_changed(new_credits: float) -> void:
	credits_display.text = "%.0f" % new_credits
	await get_tree().process_frame
	_update_collision_area(credits_container, credits_area_shape)

func _on_current_life_changed(new_life: int) -> void:
	current_life.text = str(new_life)
	await get_tree().process_frame
	_update_collision_area(life_container, life_area_shape)

func _update_collision_area(ui_control: Control, collision_shape: CollisionShape2D) -> void:
	var rect := ui_control.get_rect()
	
	collision_shape.global_position = Vector2(
		ui_control.global_position.x + rect.size.x / 2.0,
		ui_control.global_position.y + rect.size.y / 2.0,
	)
	(collision_shape.shape as RectangleShape2D).size = Vector2(rect.size.x + 50, rect.size.y + 50)

func _input(event: InputEvent) -> void:
	if controls_container.visible:
		var did_input := false
		for i in _inputs_that_clear_instructions:
			if event.is_action_pressed(i):
				did_input = true
		
		if did_input:
			# Fade out the instructions.
			if _clear_instructions_tween:
				_clear_instructions_tween.kill()
			_clear_instructions_tween = create_tween()
			_clear_instructions_tween.tween_property(controls_container, "modulate:a", 0.0, 1.5)
			_clear_instructions_tween.tween_callback(func() -> void:
				controls_container.visible = false
				controls_container.modulate.a = 1.0
			)

func _on_life_area_body_entered(_body: Node2D) -> void:
	life_container.modulate.a = 0.15

func _on_life_area_body_exited(_body: Node2D) -> void:
	life_container.modulate.a = 1

func _on_credits_area_body_entered(_body: Node2D) -> void:
	credits_container.modulate.a = 0.15

func _on_credits_area_body_exited(_body: Node2D) -> void:
	credits_container.modulate.a = 1
