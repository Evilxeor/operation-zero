class_name PlayerAbilitySystem
extends RefCounted

static func use_ability(player: Node2D) -> bool:
	if player == null or not is_instance_valid(player):
		return false
	var cooldown_value = player.get("ability_cooldown")
	if cooldown_value is float and cooldown_value > 0.0:
		return false
	if cooldown_value is int and cooldown_value > 0:
		return false
	var weapon := player.get_node_or_null("WeaponController")
	var role: int = int(player.get("role"))
	match role:
		0:
			if weapon != null:
				weapon.throw_flashbang(player.get("_aim_direction"))
			player.set("ability_cooldown", 18.0)
		1:
			player.set("recon_active", true)
			player.set("recon_timer", 5.0)
			player.set("heartbeat_timer", 0.0)
			GameRuntime.emit_noise(player.global_position, 0.0)
			player.set("ability_cooldown", 22.0)
		2:
			if weapon != null:
				weapon.set_suppressive_fire(3.0)
			player.set("ability_cooldown", 18.0)
		3:
			player.set("heartbeat_timer", 8.0)
			GameRuntime.emit_noise(player.global_position, 0.0)
			player.set("ability_cooldown", 20.0)
		_:
			return false
	return true
