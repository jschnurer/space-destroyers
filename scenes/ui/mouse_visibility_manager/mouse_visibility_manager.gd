extends Node
class_name MouseVisibilityManager

var _mouse_should_be_visible := false
var _is_using_controller := false

func _ready() -> void:
	SignalBus.toggle_mouse_visibility.connect(_on_toggle_mouse_visibility)
	_update_mouse_display()

func _input(event: InputEvent) -> void:
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
		_update_mouse_display()

func _update_mouse_display() -> void:
	if _is_using_controller or !_mouse_should_be_visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	elif _mouse_should_be_visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_toggle_mouse_visibility(visible: bool) -> void:
	_mouse_should_be_visible = visible
	_update_mouse_display()
