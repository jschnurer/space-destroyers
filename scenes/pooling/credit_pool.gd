extends Node2D
class_name CreditPool

@export var credit_scene: PackedScene
@export var credit_pool_size := 500

var _credit_pool: Array[Credit] = []

func _ready() -> void:
	_init_credit_pool()
	SignalBus.return_pooled_objects.connect(return_all)

## Initializes the bullet pool, creates the bullets, disables them.
func _init_credit_pool() -> void:
	if !credit_scene or credit_pool_size <= 0:
		return
	
	_credit_pool.resize(credit_pool_size)
	
	for i in credit_pool_size:
		var credit: Credit = credit_scene.instantiate()
		
		# Add to player bullet group so it won't be deleted on impact.
		credit.add_to_group(GroupNames.CREDIT, true)
		
		# Listen for when it leaves the screen or is collected.
		credit.return_to_pool.connect(_return_credit_to_pool.bind(credit))
		
		# Save it to the bullet pool.
		_credit_pool[i] = credit
		
		# Add to the scene.
		add_child.call_deferred(credit)
		
		# Disable and hide it.
		credit.toggle(false)

## Gets the requested number of available credits.
func get_available_credits(number: int) -> Array[Credit]:
	var creds: Array[Credit] = []
	for credit in _credit_pool:
		if credit.process_mode == ProcessMode.PROCESS_MODE_DISABLED:
			creds.append(credit)
			
			if creds.size() == number:
				break
	return creds

## Triggered when a player credit exits the screen.
func _return_credit_to_pool(credit: Credit) -> void:
	credit.toggle(false)
	credit.global_position = global_position

func return_all() -> void:
	for credit in _credit_pool:
		if credit.process_mode != ProcessMode.PROCESS_MODE_DISABLED:
			credit.toggle(false)
