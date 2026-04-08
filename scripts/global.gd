extends Node

const PLAYABLE_AREA_RECT: Rect2 = Rect2(0, 0, 1920, 1080)
const GAME_WINDOW_RECT: Rect2 = Rect2(0, 0, 1920, 1080)
## The distance the enemy descends when changing direction.
const ENEMY_DROP_DISTANCE: float = 64.0
# Credit denomination types.
var CREDIT_DENOMINATIONS: Array[CreditDenomination] = [
	CreditDenomination.new(1.0, Color.from_rgba8(153, 80, 50), 0),
	CreditDenomination.new(5.0, Color.SILVER, 1),
	CreditDenomination.new(10.0, Color.LIGHT_SLATE_GRAY, 2),
	CreditDenomination.new(50.0, Color.GOLDENROD, 3),
	CreditDenomination.new(100.0, Color.AQUA, 4),
]

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		var mode := DisplayServer.window_get_mode()

		if mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
