extends Node

const PLAYABLE_AREA_RECT: Rect2 = Rect2(0, 0, 1920, 1080)
const GAME_WINDOW_RECT: Rect2 = Rect2(0, 0, 1920, 1080)
## The distance the enemy descends when changing direction.
const ENEMY_DROP_DISTANCE: float = 64.0
# Credit denomination types.
var CREDIT_DENOMINATIONS: Array[CreditDenomination] = [
	CreditDenomination.new(1.0, Color.from_rgba8(153, 80, 50), 0),
	CreditDenomination.new(5.0, Color.LIGHT_SLATE_GRAY, 1),
	CreditDenomination.new(10.0, Color.SILVER, 2),
	CreditDenomination.new(50.0, Color.GOLDENROD, 3),
	CreditDenomination.new(100.0, Color.AQUA, 4),
]
const KENNEY_REMAP_KB_IMAGES_FOLDER_PATH := "res://art/input/kb/remap_icons"
const KENNEY_INPUT_FN_TRANSLATION: Dictionary[String,String] = {
	"Slash": "slash_forward",
	"BackSlash": "slash_back",
	"BracketLeft": "bracket_open",
	"BracketRight": "bracket_close",
	"PageUp": "page_up",
	"PageDown": "page_down",
	"Left": "arrow_left",
	"Right": "arrow_right",
	"Up": "arrow_up",
	"Down": "arrow_down",
}

## Attempts to get the file path to the kenney keyboard key icon. Returns null if no icon found.
func get_kenney_file_path_for_input(e: InputEventKey) -> String:
	var key_name := OS.get_keycode_string(e.physical_keycode)
	return get_kenney_file_path_for_key_name(key_name)

## Attempts to get the file path to the kenney keyboard key icon. Returns null if no icon found.
func get_kenney_file_path_for_key_name(key_name: String) -> String:
	var full_path := KENNEY_REMAP_KB_IMAGES_FOLDER_PATH.path_join("keyboard_" + key_name + ".png")
	var image_path: String
	
	if FileAccess.file_exists(full_path):
		image_path = full_path
	else:
		var trans: Variant = KENNEY_INPUT_FN_TRANSLATION.get(key_name)
		if trans:
			image_path = KENNEY_REMAP_KB_IMAGES_FOLDER_PATH.path_join("keyboard_" + str(trans) + ".png")
	
	return image_path

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		var mode := DisplayServer.window_get_mode()

		if mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
