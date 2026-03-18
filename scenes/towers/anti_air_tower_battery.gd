extends Node2D

func _ready() -> void:
	GameManager.upgrade_changed.connect(_on_upgrade_changed)
	_disable_all_towers()
	_enable_towers(GameManager.get_upgrade_level(Enums.PlayerUpgrades.ANTI_AIR_TOWER))

func _on_upgrade_changed(upgrade: Upgrade) -> void:
	if upgrade.upgrade != Enums.PlayerUpgrades.ANTI_AIR_TOWER:
		return
	_enable_towers(upgrade.level)

func _enable_towers(num_towers: float) -> void:
	for i in range(int(num_towers)):
		var t := find_child("Tower" + str(i + 1))
		if t and t is AntiAirTower:
			t.process_mode = Node.PROCESS_MODE_PAUSABLE
			(t as AntiAirTower).visible = true

func _disable_all_towers() -> void:
	for child in get_children():
		if child is AntiAirTower:
			child.process_mode = Node.PROCESS_MODE_DISABLED
			(child as AntiAirTower).visible = false
