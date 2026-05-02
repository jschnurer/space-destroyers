extends Node2D
class_name OrchestratedBehavior

signal behavior_complete

func emit_behavior_complete() -> void:
	behavior_complete.emit()

func handle() -> Signal:
	return behavior_complete
