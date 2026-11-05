extends RigidBody2D

@export var fuse_seconds := 1.2
@export var stun_seconds := 4.0
@export var blast_radius := 180.0
var _detonated := false


func _ready() -> void:
	await get_tree().create_timer(fuse_seconds).timeout
	if is_inside_tree():
		_detonate()


func launch(direction: Vector2) -> void:
	linear_velocity = direction.normalized() * 440.0


func _detonate() -> void:
	if _detonated:
		return
	_detonated = true
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy is Node2D and global_position.distance_to(enemy.global_position) <= blast_radius and _has_line_of_sight(enemy):
			if enemy.has_method("stun"):
				enemy.call("stun", stun_seconds)
	GameRuntime.emit_noise(global_position, 700.0)
	queue_free()


func _has_line_of_sight(target: Node2D) -> bool:
	var query := PhysicsRayQueryParameters2D.create(global_position, target.global_position, 1 | 2)
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()
