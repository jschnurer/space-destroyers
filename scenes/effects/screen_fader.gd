extends CanvasLayer
class_name ScreenFader

signal fade_complete

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

func fade_out() -> void:
	animation_player.play("fade")

func fade_in() -> void:
	animation_player.play_backwards("fade")

func _on_animation_finished(_anim_name: String) -> void:
	fade_complete.emit()
