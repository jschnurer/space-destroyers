extends Node2D
class_name PlayerBulletPool

@export var bullet_scene: PackedScene
@export var bullet_pool_size := 100

var _bullet_pool: Array[Bullet] = []

func _ready() -> void:
	_init_bullet_pool()
	SignalBus.return_pooled_objects.connect(return_all)

## Initializes the bullet pool, creates the bullets, disables them.
func _init_bullet_pool() -> void:
	if !bullet_scene or bullet_pool_size <= 0:
		return
	
	_bullet_pool.resize(bullet_pool_size)
	
	for i in range(bullet_pool_size):
		var bullet: Bullet = bullet_scene.instantiate()
		
		# Add to player bullet group so it won't be deleted on impact.
		bullet.add_to_group(GroupNames.PLAYER_BULLET, true)
		
		# Set collision.
		bullet.set_collision(1 << 3, 1 << 1)
		
		# Don't want to delete when it leaves the screen! Remove the "delete offscreen" component.
		var comp := Utilities.get_first_child_of_type(bullet, DeleteOffscreenComponent)
		if comp:
			comp.free()
		
		# Add a trigger to detect when it leaves the screen to disable it.
		var vis := VisibleOnScreenNotifier2D.new()
		vis.rect = Rect2(-.5, -2, 1, 4)
		vis.screen_exited.connect(_on_bullet_screen_exited.bind(bullet))
		bullet.find_child("Components").add_child(vis)
		
		# Save it to the bullet pool.
		_bullet_pool[i] = bullet
		
		# Add to the scene.
		add_child.call_deferred(bullet)
		
		# Disable and hide it.
		bullet.toggle_bullet(false)

## Gets the requested number of available bullets.
func get_available_bullets(number: int) -> Array[Bullet]:
	var bullets: Array[Bullet] = []
	for bullet in _bullet_pool:
		if bullet.process_mode == ProcessMode.PROCESS_MODE_DISABLED:
			bullets.append(bullet)
			
			if bullets.size() == number:
				break
	return bullets

## Triggered when a player bullet exits the screen.
func _on_bullet_screen_exited(bullet: Bullet) -> void:
	bullet.toggle_bullet(false)

func return_all() -> void:
	for bullet in _bullet_pool:
		if bullet.process_mode != ProcessMode.PROCESS_MODE_DISABLED:
			bullet.toggle_bullet(false)
