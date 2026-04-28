extends Node

var ffwd_time_scale := 6.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("fast_forward"):
		Engine.time_scale = ffwd_time_scale
	elif Input.is_action_just_released("fast_forward"):
		Engine.time_scale = 1
