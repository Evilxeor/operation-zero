extends Node

func current_scene() -> Node:
	var tree := get_tree()
	if tree == null:
		return null
	if tree.current_scene != null and is_instance_valid(tree.current_scene):
		return tree.current_scene
	return self


func get_player() -> Node2D:
	var tree := get_tree()
	if tree == null:
		return null
	var player := tree.get_first_node_in_group("player")
	if player is Node2D:
		return player as Node2D
	return null


func get_operative_nodes() -> Array:
	var tree := get_tree()
	if tree == null:
		return []
	var operatives: Array = []
	for operative in tree.get_nodes_in_group("operative"):
		if is_instance_valid(operative) and operative is Node2D:
			operatives.append(operative)
	return operatives


func get_enemy_nodes() -> Array:
	var tree := get_tree()
	if tree == null:
		return []
	var enemies: Array = []
	for enemy in tree.get_nodes_in_group("enemy"):
		if is_instance_valid(enemy) and enemy is Node2D:
			enemies.append(enemy)
	return enemies


func emit_noise(world_position: Vector2, radius: float) -> void:
	var manager := get_tree().root.get_node_or_null("/root/SoundManager")
	if manager != null and manager.has_method("emit_noise"):
		manager.call("emit_noise", world_position, radius)
		return
	var scene := current_scene()
	if scene != null and scene.has_method("emit_noise"):
		scene.call("emit_noise", world_position, radius)


func spawn_splat(world_position: Vector2, color: Color) -> void:
	var manager := get_tree().root.get_node_or_null("/root/PaintManager")
	if manager != null and manager.has_method("spawn_splat"):
		manager.call("spawn_splat", world_position, color)
		return
	var scene := current_scene()
	if scene != null and scene.has_method("spawn_splat"):
		scene.call("spawn_splat", world_position, color)
