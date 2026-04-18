extends Line2D
class_name LaserSight

@export var laser_scroll_speed := 100.0

var _laser_offset := 0.0
var _shader_mat: ShaderMaterial

func _ready() -> void:
	Game.upgrade_changed.connect(_on_upgrade_changed.unbind(1))
	
	_update_visibility()
	
	if material and material is ShaderMaterial:
		_shader_mat = material as ShaderMaterial

func _process(delta: float) -> void:
	if !visible:
		return
	
	_laser_offset += laser_scroll_speed * delta
	_shader_mat.set_shader_parameter("scroll_offset", _laser_offset)

func _update_visibility() -> void:
	visible = Game.has_upgrade(Enums.PlayerUpgrades.LASER_SIGHT)

func _on_upgrade_changed() -> void:
	_update_visibility()
