class_name CreditDenomination

# The coin value of this denomination.
@export var value: float
# The color of this denomination.
@export var color: Color
# The denomination's index in the global array (to avoid FINDing every time it's needed to step down.)
@export var array_index: int

func _init(p_value: float, p_color: Color, p_array_index: int) -> void:
	value = p_value
	color = p_color
	array_index = p_array_index
