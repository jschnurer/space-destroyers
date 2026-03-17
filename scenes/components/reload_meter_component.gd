extends ColorRect
class_name ReloadMeterComponent

@export var reload_component: ReloadComponent

@onready var full_width := size.x

func _ready() -> void:
	visible = false
	if reload_component:
		reload_component.reload_started.connect(_on_reload_started)
		reload_component.reload_complete.connect(_on_reload_complete)

func _process(_delta: float) -> void:
	if !reload_component or !reload_component.is_reloading():
		return
	
	size.x = reload_component.get_reload_progress() * full_width

func _on_reload_started() -> void:
	visible = true
	size.x = 0

func _on_reload_complete() -> void:
	visible = false
