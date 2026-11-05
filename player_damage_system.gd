class_name PlayerDamageSystem
extends RefCounted

static func apply_damage(player: Node2D, amount: float, source: Node = null) -> bool:
	if player == null or not is_instance_valid(player):
		return false
	if player.get("is_dead") == true or amount <= 0.0:
		return false
	var final_damage := amount
	var source_position := source.global_position if source is Node2D else Vector2.ZERO
	var incoming := source_position - player.global_position
	if player.get("_in_cover") == true and incoming.length_squared() > 0.01 and incoming.normalized().dot(-player.get("_cover_normal")) > 0.55:
		final_damage *= 0.6
	if player.get("armor_plates") > 0 and incoming.length_squared() > 0.01 and absf(wrapf(incoming.angle() - player.global_rotation, -PI, PI)) < PI * 0.6:
		var absorbed := minf(player.get("armor_per_plate"), final_damage * 0.65)
		final_damage -= absorbed
		player.set("armor_plates", int(player.get("armor_plates")) - 1)
	player.set("health", clampf(float(player.get("health")) - final_damage, 0.0, float(player.get("max_health"))))
	player.health_changed.emit(player.health, player.max_health)
	if player.health <= 0.0:
		player.set("is_dead", true)
		player.player_died.emit()
		MissionManager.fail_mission()
		return true
	return true
