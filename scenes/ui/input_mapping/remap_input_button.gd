@tool
extends Button
class_name RemapInputButton

@export var action_name: String
@export var key_name: String:
	set(value):
		($Icon as KenneyKBInputTextureRect).key_name = value
	get():
		return ($Icon as KenneyKBInputTextureRect).key_name
@export var is_keyboard := true

## The label that holds the display name for this action.
@export var display_label: Label
## The popup to show to enable remapping the input.
@export var remap_popup_scene: PackedScene

signal remap_input(action_name: String, input_event: InputEvent, key_name: String, \
	is_keyboard: bool, remap_button: RemapInputButton)

func _on_pressed() -> void:
	if !remap_popup_scene or !remap_popup_scene.can_instantiate():
		return
	
	var popup: RemapInputPopup = remap_popup_scene.instantiate()
	popup.input_accepted.connect(_on_input_accepted)
	get_tree().current_scene.add_child(popup)
	popup.set_action_name(display_label.text)

func _on_input_accepted(input_event: InputEvent, p_key_name: String) -> void:
	remap_input.emit(action_name, input_event, p_key_name, is_keyboard, self)
