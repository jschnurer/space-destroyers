extends Control
class_name InputMappingUI

signal closed

func _ready() -> void:
	var remap_buttons := get_tree().get_nodes_in_group("REMAP_BUTTONS")
	for btn: RemapInputButton in remap_buttons:
		btn.remap_input.connect(_on_remap_input)
		_update_button_display(btn)

func toggle(is_enabled: bool) -> void:
	visible = is_enabled
	if !is_enabled:
		closed.emit()
	else:
		var first_btn := get_tree().get_first_node_in_group("REMAP_BUTTONS")
		if first_btn:
			(first_btn as Control).grab_focus()

func _on_back_pressed() -> void:
	toggle(false)

func _on_remap_input(action_name: String, input_event: InputEvent, \
	key_name: String, is_keyboard: bool, remap_button: RemapInputButton) -> void:
	# Erase existing event for this input action.
	var events := InputMap.action_get_events(action_name)
	for event in events:
		if event is InputEventKey and is_keyboard:
			# Found match to replace keyboard event.
			InputMap.action_erase_event(action_name, event)
			break
	
	# Add the new input action event.
	InputMap.action_add_event(action_name, input_event)
	
	remap_button.key_name = key_name
	UserConfig.save_controls()

func _update_button_display(button: RemapInputButton) -> void:
	var events := InputMap.action_get_events(button.action_name)
	
	for event in events:
		if event is InputEventKey and button.is_keyboard:
			var key_name := OS.get_keycode_string((event as InputEventKey).physical_keycode)
			button.key_name = key_name
		elif event is InputEventJoypadButton and !button.is_keyboard:
			# TODO: Handle loading in joy buttons too.
			pass
