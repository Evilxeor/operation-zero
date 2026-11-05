class_name RoleProfile
extends RefCounted

const ARMOR_CAPS := {
	0: 5,
	1: 2,
	2: 4,
	3: 2,
}

const WEAPON_STATS := {
	0: {
		"damage": 34.0,
		"fire_rate": 7.0,
		"noise_radius": 280.0,
		"ability_cooldown": 18.0,
		"armor_cap": 5,
	},
	1: {
		"damage": 28.0,
		"fire_rate": 8.0,
		"noise_radius": 280.0,
		"ability_cooldown": 22.0,
		"armor_cap": 2,
	},
	2: {
		"damage": 42.0,
		"fire_rate": 5.0,
		"noise_radius": 280.0,
		"ability_cooldown": 18.0,
		"armor_cap": 4,
	},
	3: {
		"damage": 32.0,
		"fire_rate": 7.0,
		"noise_radius": 70.0,
		"ability_cooldown": 20.0,
		"armor_cap": 2,
	},
}

static func armor_cap(role_index: int) -> int:
	if ARMOR_CAPS.has(role_index):
		return ARMOR_CAPS[role_index]
	return 1


static func weapon_stats(role_index: int) -> Dictionary:
	if WEAPON_STATS.has(role_index):
		return WEAPON_STATS[role_index].duplicate()
	return WEAPON_STATS[0].duplicate()


static func fov_bonus(role_index: int) -> float:
	if role_index == 1:
		return 30.0
	return 0.0


static func ability_name(role_index: int) -> String:
	var names := ["FLASH", "RECON PULSE", "SUPPRESS", "SENSOR"]
	if role_index >= 0 and role_index < names.size():
		return names[role_index]
	return "ABILITY"
