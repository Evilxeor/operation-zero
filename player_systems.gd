class_name PlayerSystems
extends RefCounted

static func turn_rate_for_stance(stance: int) -> float:
	if stance == 2:
		return 2.4
	if stance == 1:
		return 5.0
	return 9.0


static func effective_fov(base_fov: float, role: int, stance: int) -> float:
	var result := base_fov + RoleProfile.fov_bonus(role)
	if stance == 2:
		result -= 15.0
	return result


static func effective_vision_range(base_range: float, stance: int) -> float:
	return base_range * (0.72 if stance == 2 else 1.0)


static func cover_state_for(player: Node2D) -> Dictionary:
	var in_cover := false
	var cover_normal := Vector2.ZERO
	var closest_distance := INF
	for index in range(16):
		var direction := Vector2.RIGHT.rotated(TAU * float(index) / 16.0)
		var query := PhysicsRayQueryParameters2D.create(player.global_position, player.global_position + direction * 34.0, 1)
		query.exclude = [player.get_rid()]
		var hit := player.get_world_2d().direct_space_state.intersect_ray(query)
		if hit.is_empty():
			continue
		var collider: Object = hit.collider
		if collider is Node and (collider as Node).is_in_group("soft_cover"):
			var distance: float = player.global_position.distance_to(hit.position)
			if distance < closest_distance:
				closest_distance = distance
				in_cover = true
				cover_normal = hit.normal
	return {
		"in_cover": in_cover,
		"normal": cover_normal,
	}
