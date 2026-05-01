extends Node

const CONTROLS_PATH := "user://controls.cfg"
const OPTIONS_PATH := "user://options.cfg"

func _enter_tree() -> void:
	load_controls()
	load_options()

func load_controls() -> void:
	var config := ConfigFile.new()
	if config.load(CONTROLS_PATH) != OK:
		return

	for action in config.get_sections():
		InputMap.action_erase_events(action)
		
		if config.has_section_key(action, "keyboard_key"):
			var key := InputEventKey.new()
			key.physical_keycode = config.get_value(action, "keyboard_key")
			InputMap.action_add_event(action, key)
			
		if config.has_section_key(action, "joy_button"):
			var joy_btn := InputEventJoypadButton.new()
			joy_btn.button_index = config.get_value(action, "joy_button")
			InputMap.action_add_event(action, joy_btn)
			
		if config.has_section_key(action, "joy_axis"):
			var joy_mov := InputEventJoypadMotion.new()
			joy_mov.axis = config.get_value(action, "joy_axis")
			joy_mov.axis_value = config.get_value(action, "joy_axis_value")
			InputMap.action_add_event(action, joy_mov)

func save_controls() -> void:
	var config := ConfigFile.new()
	for action in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue
		var events := InputMap.action_get_events(action)
		for event in events:
			if event is InputEventKey:
				config.set_value(action, "keyboard_key", (event as InputEventKey).physical_keycode)
			elif event is InputEventJoypadButton:
				config.set_value(action, "joy_button", (event as InputEventJoypadButton).button_index)
			elif event is InputEventJoypadMotion:
				config.set_value(action, "joy_axis", (event as InputEventJoypadMotion).axis)
				config.set_value(action, "joy_axis_value", (event as InputEventJoypadMotion).axis_value)
	
	config.save(CONTROLS_PATH)

func load_options() -> void:
	var config := ConfigFile.new()
	if config.load(OPTIONS_PATH) != OK:
		return
	FastForward.ffwd_time_scale = config.get_value("ffwd", "speed", 6)

func save_options() -> void:
	var config := ConfigFile.new()
	config.set_value("ffwd", "speed", FastForward.ffwd_time_scale)
	config.save(OPTIONS_PATH)
