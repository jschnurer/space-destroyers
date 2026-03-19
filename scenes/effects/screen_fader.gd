extends CanvasLayer
class_name ScreenFader

signal fade_complete

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

func fade_out() -> Signal:
	animation_player.play("fade")
	return fade_complete

func fade_in() -> Signal:
	animation_player.play_backwards("fade")
	return fade_complete

func _on_animation_finished(_anim_name: String) -> void:
	fade_complete.emit()
