extends Control
class_name SettingsUI

@export var show_input_mapping := true

signal settings_closed

@onready var ffwd_speed: Label = %FFWDSpeed
@onready var input_mapping: Button = %"Input Mapping"
@onready var speed_entry: HBoxContainer = %SpeedEntry
@onready var input_mapping_ui: InputMappingUI = %InputMappingUI
@onready var settings_menu_input: MarginContainer = %SettingsMenuInput

func _ready() -> void:
	input_mapping.visible = show_input_mapping
	_update_ffwd_label()
	_toggle_input_map(false)
	input_mapping_ui.process_mode = Node.PROCESS_MODE_DISABLED

func toggle(is_enabled: bool) -> void:
	visible = is_enabled
	if !is_enabled:
		settings_closed.emit()
	else:
		if show_input_mapping:
			input_mapping.grab_focus()
		else:
			ffwd_speed.grab_focus()

func _on_ffwd_plus_pressed() -> void:
	FastForward.ffwd_time_scale = clampf(FastForward.ffwd_time_scale + 1, 2, 10)
	_update_ffwd_label()

func _on_ffwd_minus_pressed() -> void:
	FastForward.ffwd_time_scale = clampf(FastForward.ffwd_time_scale - 1, 2, 10)
	_update_ffwd_label()

func _update_ffwd_label() -> void:
	ffwd_speed.text = "%.0f" % FastForward.ffwd_time_scale + "x"

func _on_ffwd_speed_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left"):
		_on_ffwd_minus_pressed()
		accept_event()
	elif event.is_action_pressed("move_right"):
		_on_ffwd_plus_pressed()
		accept_event()

func _on_back_pressed() -> void:
	toggle(false)

func _toggle_input_map(is_enabled: bool) -> void:
	settings_menu_input.process_mode = Node.PROCESS_MODE_DISABLED if is_enabled == true else Node.PROCESS_MODE_PAUSABLE
	settings_menu_input.visible = !is_enabled
	input_mapping_ui.process_mode = Node.PROCESS_MODE_PAUSABLE if is_enabled == true else Node.PROCESS_MODE_DISABLED
	input_mapping_ui.visible = is_enabled
	if !is_enabled:
		input_mapping.grab_focus()
	else:
		input_mapping_ui.toggle(true)

func _on_input_mapping_ui_closed() -> void:
	_toggle_input_map(false)

func _on_input_mapping_pressed() -> void:
	_toggle_input_map(true)
