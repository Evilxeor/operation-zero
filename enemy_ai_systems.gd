class_name EnemyAISystems
extends RefCounted

static func effective_detection_range(enemy: CharacterBody2D, target: Node2D) -> float:
	if enemy == null or target == null or not is_instance_valid(target):
		return 0.0
	var stance := target.get_stance() if target.has_method("get_stance") else 0
	return enemy.get("detection_range") * (0.62 if stance == 2 else (0.8 if stance == 1 else 1.0))


static func target_visible(enemy: CharacterBody2D, target: Node2D) -> bool:
	if enemy == null or target == null or not is_instance_valid(target):
		return false
	var offset := target.global_position - enemy.global_position
	var in_fov := absf(wrapf(offset.angle() - enemy.global_rotation, -PI, PI)) <= deg_to_rad(float(enemy.get("field_of_view_degrees")) * 0.5)
	var ray := enemy.get_node_or_null("VisionRaycast") as RayCast2D
	if ray != null:
		ray.target_position = enemy.to_local(target.global_position)
		ray.force_raycast_update()
	return in_fov and (ray == null or not ray.is_colliding() or ray.get_collider() == target)


static func can_hear_noise(enemy: CharacterBody2D, source: Vector2, radius: float) -> bool:
	if enemy == null or radius <= 0.0:
		return false
	return enemy.global_position.distance_to(source) <= radius


static func is_visible_to_squad(enemy: CharacterBody2D) -> bool:
	for member in enemy.get_tree().get_nodes_in_group("operative"):
		if member == enemy or not member is Node2D:
			continue
		var offset: Vector2 = enemy.global_position - member.global_position
		if offset.length() > 440.0:
			continue
		var query := PhysicsRayQueryParameters2D.create(member.global_position, enemy.global_position, 1 | 2)
		query.exclude = [member.get_rid()]
		if enemy.get_world_2d().direct_space_state.intersect_ray(query).is_empty():
			return true
	return false


static func rotation_toward_target(enemy: CharacterBody2D, target_position: Vector2) -> void:
	enemy.rotation = (target_position - enemy.global_position).angle()
