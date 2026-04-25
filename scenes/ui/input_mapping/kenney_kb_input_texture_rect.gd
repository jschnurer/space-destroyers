@tool
extends TextureRect
class_name KenneyKBInputTextureRect

@export var remap_images_folder := "res://art/input/kb/remap_icons"
@export var key_name: String:
	set(value):
		key_name = value
		_update_icon(value)

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
func _get_kenney_file_path_for_key_name(p_key_name: String) -> String:
	var full_path := KENNEY_REMAP_KB_IMAGES_FOLDER_PATH.path_join("keyboard_" + p_key_name + ".png")
	var image_path: String
	
	if FileAccess.file_exists(full_path):
		image_path = full_path
	else:
		var trans: Variant = KENNEY_INPUT_FN_TRANSLATION.get(p_key_name)
		if trans:
			image_path = KENNEY_REMAP_KB_IMAGES_FOLDER_PATH.path_join("keyboard_" + str(trans) + ".png")
	
	return image_path
#
#func _unhandled_input(event: InputEvent) -> void:
	#if event is not InputEventKey or !event.is_pressed():
		#return
	#
	#var e: InputEventKey = event
	#var image_path := Global.get_kenney_file_path_for_input(e)
	#if image_path:
		#texture = load(image_path)

func _update_icon(p_key_code: String) -> void:
	var image_path := _get_kenney_file_path_for_key_name(p_key_code)
	if image_path:
		texture = load(image_path)
