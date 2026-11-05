extends Area2D

@export var speed := 1000.0
@export var damage := 34.0
@export var max_distance := 1100.0

var direction := Vector2.RIGHT
var faction := "player"
var shooter: Node2D
var _travelled := 0.0
var _penetration_used := false
var _damage_scale := 1.0


func _ready() -> void:
	collision_layer = 16
	collision_mask = 0
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	var step := direction.normalized() * speed * delta
	var destination := global_position + step
	var query := PhysicsRayQueryParameters2D.create(global_position, destination, 1 | 2 | 4 | 8)
	if shooter != null and is_instance_valid(shooter):
		query.exclude = [shooter.get_rid()]
	var space := get_world_2d().direct_space_state
	for _attempt in range(5):
		var hit := space.intersect_ray(query)
		if hit.is_empty():
			global_position = destination
			_travelled += step.length()
			if _travelled >= max_distance:
				queue_free()
			return
		var collider: Object = hit.collider
		if collider is Node and _is_friendly(collider as Node):
			query.exclude.append((collider as CollisionObject2D).get_rid())
			continue
		if not _penetration_used and collider is Node and (collider as Node).is_in_group("soft_cover"):
			_penetration_used = true
			_damage_scale = 0.55
			query.exclude.append((collider as CollisionObject2D).get_rid())
			continue
		global_position = hit.position
		_apply_hit(collider)
		queue_free()
		return
	global_position = destination
	_travelled += step.length()
	if _travelled >= max_distance:
		queue_free()


func _is_friendly(target: Node) -> bool:
	if faction == "player":
		return target.is_in_group("operative") or target.is_in_group("player")
	return target.is_in_group("enemy")


func _apply_hit(target: Object) -> void:
	if not target is Node:
		return
	var node := target as Node
	if faction == "player" and node.is_in_group("enemy"):
		node.call("take_damage", damage * _damage_scale, shooter)
		if shooter is Node2D and shooter.has_method("get") and shooter.get("weapon_controller") != null and shooter.get("weapon_controller").is_suppressing():
			node.call("apply_suppression", 2.0)
	elif faction == "enemy" and (node.is_in_group("player") or node.is_in_group("operative")):
		node.call("take_damage", damage * _damage_scale, shooter)
	elif node.has_method("take_damage"):
		node.call("take_damage", damage * _damage_scale, shooter)
	else:
		GameRuntime.spawn_splat(global_position, Color(0.8, 0.65, 0.25, 0.8))
