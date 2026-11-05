class_name WorldQuery
extends RefCounted

static func nearest_in_group(origin: Node2D, group_name: String, max_distance: float = INF) -> Node2D:
	var best: Node2D
	var best_distance := max_distance
	for candidate in origin.get_tree().get_nodes_in_group(group_name):
		if not candidate is Node2D or not is_instance_valid(candidate):
			continue
		var distance := origin.global_position.distance_to(candidate.global_position)
		if distance <= best_distance:
			best_distance = distance
			best = candidate
	return best


static func visible_to_player(from: Node2D, target: Node2D) -> bool:
	if from == null or target == null:
		return false
	var query := PhysicsRayQueryParameters2D.create(from.global_position, target.global_position, 1 | 2)
	query.exclude = [from.get_rid()]
	return from.get_world_2d().direct_space_state.intersect_ray(query).is_empty()
