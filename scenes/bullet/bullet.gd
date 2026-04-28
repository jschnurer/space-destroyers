extends BaseProjectile
class_name Bullet

## If true, this bullet can flak enemies.
@export var can_flak := false

@onready var hitbox_component: HitboxComponent = %HitboxComponent

func _ready() -> void:
	if can_flak:
		($Components/HitboxComponent as HitboxComponent).can_flak = true

func _on_hitbox_component_dealt_damage(_hurtbox_component: HurtboxComponent) -> void:
	($Components/HitboxComponent as HitboxComponent).is_active = false
	if !is_in_group(GroupNames.PLAYER_BULLET):
		queue_free()
	else:
		toggle_bullet(false)

func toggle_bullet(is_enabled: bool) -> void:
	visible = is_enabled
	process_mode = Node.PROCESS_MODE_INHERIT if is_enabled else Node.PROCESS_MODE_DISABLED
	
	var hb: HitboxComponent = hitbox_component if hitbox_component != null else %HitboxComponent
	hb.set_deferred("monitoring", is_enabled)
	hb.set_deferred("monitorable", is_enabled)
	hb.is_active = true
