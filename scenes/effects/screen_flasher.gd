extends CanvasLayer
class_name ScreenFlasher

@onready var color_rect: ColorRect = %ColorRect
var _fade_tween: Tween

func _ready() -> void:
	SignalBus.flash_screen.connect(_flash_screen)

func _flash_screen(color: Color, fade_dur: float) -> void:
	color_rect.modulate.a = 1
	color_rect.color = color
	if _fade_tween:
		_fade_tween.kill()
	
	_fade_tween = create_tween()
	_fade_tween.tween_property(color_rect, "modulate:a", 0.0, fade_dur)
