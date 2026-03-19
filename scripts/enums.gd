extends Node

enum ScreenEdges {
	LEFT,
	RIGHT,
}

enum CollisionLayers {
	PLAYER = 0,
	ENEMY = 1,
	SCREEN_EDGE = 2,
	PLAYER_BULLET = 3,
	TERRAIN = 4,
}

enum PlayerStats {
	TANK_SPEED = 0,
	MAX_SHOTS = 1,
	RELOAD = 2,
	DAMAGE = 3,
	SHOT_SPEED = 4,
	PICKUP_AREA = 5,
	CREDIT_MULTIPLIER = 6,
	LUCK = 7,
	LIFE = 8,
}

enum PlayerUpgrades {
	FULL_AUTO = 0,
	MISSILES = 1,
	LASER_SIGHT = 2,
	MULTI_CANNON = 3,
	ANTI_AIR_TOWER = 4,
	BARRICADE = 5,
	LIGHTNING_TOWER = 6,
	RETAINING_WALL_LEFT = 7,
	RETAINING_WALL_RIGHT = 8
}

enum EnemyType {
	CRAB = 0,
	OCTOPUS = 1,
	SQUID = 2,
	UFO = 3,
}
