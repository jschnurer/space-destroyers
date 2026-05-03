extends OrchestratedBehavior
class_name ToggleAutoShootBehavior

@export var autoshoot_enabled: bool
@export var nodes_with_autoshoot: Array[Node2D]

func handle() -> Signal:
	for n in nodes_with_autoshoot:
		if !n:
			continue
		var comp: AutoShootComponent = Utilities.get_first_child_of_type(n, AutoShootComponent)
		if comp:
			comp.toggle(autoshoot_enabled)
	
	# Emit the signal deferred, so the caller can connect to it first.
	behavior_complete.emit.call_deferred()
	
	return behavior_complete
