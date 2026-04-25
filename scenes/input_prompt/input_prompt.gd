@tool
extends TextureRect
class_name InputPromptLabel

enum InputAction {
	CONFIRM,
	CANCEL,
	MOVEMENT,
	UP,
	DOWN,
	LEFT,
	RIGHT,
	FAST_FORWARD,
}

@export var is_controller_testing: bool:
	set(value):
		is_controller_testing = value
		_is_using_controller = value
		_update_icon()

@export var action: InputAction = InputAction.CONFIRM:
	set(value):
		action = value
		_update_icon()

@export var auto_change_on_input := true

@export var controller_images: Dictionary[InputAction, Texture2D]
@export var keyboard_images: Dictionary[InputAction, Texture2D]

var _is_using_controller: bool = false

func _input(event: InputEvent) -> void:
	if !auto_change_on_input:
		return
		
	var is_controller := false
	
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		is_controller = true
	elif event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
		is_controller = false
	else:
		# Weird input device??
		return
	
	if is_controller != _is_using_controller:
		_is_using_controller = is_controller
		_update_icon()

func _update_icon() -> void:
	if _is_using_controller:
		texture = controller_images[action]
	else:
		texture = keyboard_images[action]
