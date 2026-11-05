extends CharacterBody2D

@export var move_speed := 165.0
@export var follow_distance := 58.0
@export var fire_interval := 1.3
@export var bullet_scene: PackedScene = preload("res://scenes/objects/bullet.tscn")

var _player: Node2D
var _fire_timer := 0.0
var _command := "regroup"
var _hold_fire := false
var _hold_position := false
var _command_position := Vector2.ZERO
var _has_command_position := false
var _designated_target: Node2D
var _squad_index := 0
var _breach_target: Node2D


func _ready() -> void:
	add_to_group("operative")
	_player = get_tree().get_first_node_in_group("player") as Node2D
	var flashlight := get_node_or_null("Flashlight") as PointLight2D
	if flashlight != null:
		flashlight.texture = LightTextures.soft_radial
		flashlight.texture_scale = 3.5
	var squad_members := get_tree().get_nodes_in_group("operative")
	for member_index in range(squad_members.size()):
		if squad_members[member_index] == self:
			_squad_index = member_index
			break


func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
	_fire_timer = maxf(_fire_timer - delta, 0.0)
	if _player == null:
		return
	if _command == "breach":
		_update_breach_order()
	var destination := _get_destination()
	var offset := destination - global_position
	if not _hold_position and offset.length() > follow_distance:
		var move_direction := offset.normalized()
		var query := PhysicsRayQueryParameters2D.create(global_position, global_position + move_direction * 74.0, 1 | 2)
		query.exclude = [get_rid()]
		if not get_world_2d().direct_space_state.intersect_ray(query).is_empty():
			var left_direction := move_direction.rotated(-PI / 3.0)
			var right_direction := move_direction.rotated(PI / 3.0)
			var left_query := PhysicsRayQueryParameters2D.create(global_position, global_position + left_direction * 74.0, 1 | 2)
			var right_query := PhysicsRayQueryParameters2D.create(global_position, global_position + right_direction * 74.0, 1 | 2)
			left_query.exclude = [get_rid()]
			right_query.exclude = [get_rid()]
			if get_world_2d().direct_space_state.intersect_ray(left_query).is_empty():
				move_direction = left_direction
			elif get_world_2d().direct_space_state.intersect_ray(right_query).is_empty():
				move_direction = right_direction
			else:
				move_direction = Vector2.ZERO
		velocity = move_direction * move_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	_engage_target()


func set_command(command: String) -> void:
	_command = command
	_hold_position = command == "hold"
	_hold_fire = command == "hold_fire"
	_has_command_position = false
	_designated_target = null
	match command:
		"move":
			_command_position = _player.global_position + Vector2.RIGHT.rotated(_player.global_rotation) * 220.0
			_has_command_position = true
		"cover":
			_command_position = _player.global_position - Vector2.RIGHT.rotated(_player.global_rotation) * 90.0
			_has_command_position = true
		"hold":
			_command_position = global_position
			_has_command_position = true
		"split":
			_command_position = SquadBehavior.get_split_destination(_player.global_position, _player.global_rotation, _squad_index)
			_has_command_position = true
		"target":
			_designated_target = _nearest_enemy()
		"breach":
			_breach_target = _nearest_closed_door()
			_hold_position = _breach_target == null
			if _breach_target != null:
				_command_position = _breach_target.global_position - Vector2.RIGHT.rotated(_breach_target.global_rotation) * 58.0
				_command_position += Vector2.DOWN.rotated(_breach_target.global_rotation) * (float(_squad_index) - 1.5) * 24.0
				_has_command_position = true
		"stack", "regroup":
			_hold_position = false
		"free":
			_hold_position = false


func move_to_mark(mark: Vector2) -> void:
	_command = "move"
	_command_position = mark
	_has_command_position = true
	_hold_position = false
	_hold_fire = false
	_designated_target = null


func _get_destination() -> Vector2:
	if _has_command_position:
		if _command == "regroup" or _command == "stack":
			return SquadBehavior.get_default_destination(_squad_index, _player.global_position, _player.global_rotation)
		return _command_position
	return SquadBehavior.get_default_destination(_squad_index, _player.global_position, _player.global_rotation)


func _update_breach_order() -> void:
	if _breach_target == null or not is_instance_valid(_breach_target):
		return
	if _breach_target.get("is_open") == true:
		_command_position = _breach_target.global_position + Vector2.RIGHT.rotated(_breach_target.global_rotation) * 100.0
		_hold_position = false
		_command = "free"


func _engage_target() -> void:
	var enemy := _designated_target if is_instance_valid(_designated_target) else _nearest_enemy()
	if enemy == null:
		return
	var aim := enemy.global_position - global_position
	rotation = aim.angle()
	var ray := get_node_or_null("VisionRaycast") as RayCast2D
	var can_see := true
	if ray != null:
		ray.target_position = to_local(enemy.global_position)
		ray.force_raycast_update()
		can_see = not ray.is_colliding() or ray.get_collider() == enemy
	if can_see and not _hold_fire and _fire_timer == 0.0:
		_fire_timer = fire_interval
		var bullet := bullet_scene.instantiate()
		bullet.global_position = get_node("Muzzle").global_position
		bullet.set("direction", aim.normalized())
		bullet.set("faction", "player")
		bullet.set("shooter", self)
		get_tree().current_scene.add_child(bullet)


func _nearest_enemy() -> Node2D:
	return WorldQuery.nearest_in_group(self, "enemy", 520.0)


func _nearest_closed_door() -> Node2D:
	var closest: Node2D
	var best_distance := 240.0
	for candidate in get_tree().get_nodes_in_group("interactable"):
		if not candidate is Node2D or candidate.get("is_open") != false:
			continue
		var distance := global_position.distance_to(candidate.global_position)
		if distance < best_distance:
			best_distance = distance
			closest = candidate
	return closest
