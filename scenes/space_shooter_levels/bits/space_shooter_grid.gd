@tool
extends Node2D
class_name SpaceShooterGrid

@export var screen_height := 1080
@export var screen_width := 1920
@export var num_lines := 50
@export var line_width := 10.0
@export var line_color := Color.AQUA

func _draw() -> void:
	if !Engine.is_editor_hint():
		return
	
	for i in range(num_lines):
		draw_rect(Rect2(Vector2(0, -i * screen_height), \
			Vector2(screen_width, screen_height)), line_color, false, line_width)
