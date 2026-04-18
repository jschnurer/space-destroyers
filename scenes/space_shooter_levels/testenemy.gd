extends Sprite2D

var pos_offset := 0.0
var _time := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_time += delta
	pos_offset = sin(_time) * 250.0
	offset.x = pos_offset
