extends CanvasLayer
class_name ScreenFader

signal fade_complete

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = %ColorRect

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	SignalBus.fade_in_screen.connect(_fade_in_screen)
	SignalBus.fade_out_screen.connect(_fade_out_screen)

func _fade_out_screen(duration: float, color: Color) -> void:
	color_rect.color = color
	if duration == 0:
		SignalBus.emit_fade_out_complete()
	else:
		animation_player.speed_scale = animation_player.get_animation("fade").length / duration
		animation_player.play("fade")
		await animation_player.animation_finished
		SignalBus.emit_fade_out_complete()

func _fade_in_screen(duration: float) -> void:
	animation_player.speed_scale = animation_player.get_animation("fade").length / duration
	animation_player.play_backwards("fade", -1)
	await animation_player.animation_finished
	SignalBus.emit_fade_in_complete()

func _on_animation_finished(_anim_name: String) -> void:
	fade_complete.emit()
