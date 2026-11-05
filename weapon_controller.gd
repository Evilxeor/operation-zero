extends Node

signal ammo_changed(current: int, maximum: int)

@export var magazine_size := 30
@export var reserve_ammo := 120
@export var rounds_per_second := 7.0
@export var base_damage := 34.0
@export var bullet_scene: PackedScene = preload("res://scenes/objects/bullet.tscn")
@export var flashbang_scene: PackedScene = preload("res://scenes/objects/flashbang.tscn")

var ammo := 30
var _cooldown := 0.0
var _bloom := 0.0
var _suppressive_timer := 0.0
var _damage_scale := 1.0
var _operator: Node2D
var _role := 0
var _base_damage := 34.0
var _auto_fire := false


func _ready() -> void:
	_operator = get_parent() as Node2D
	ammo = magazine_size
	ammo_changed.emit(ammo, magazine_size)


func _process(delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)
	_bloom = maxf(_bloom - delta * 0.55, 0.0)
	if _suppressive_timer > 0.0:
		_suppressive_timer = maxf(_suppressive_timer - delta, 0.0)
		if _suppressive_timer == 0.0:
			_damage_scale = 1.0
	if _auto_fire and _operator != null and _operator.get("is_dead") != true:
		var target := _auto_fire_target()
		if target != null:
			fire(target.global_position - _operator.global_position)


func fire(direction: Vector2) -> void:
	if _operator == null or ammo <= 0 or _cooldown > 0.0 or direction.length_squared() < 0.01:
		return
	_cooldown = 1.0 / maxf(rounds_per_second, 0.1)
	ammo -= 1
	ammo_changed.emit(ammo, magazine_size)
	var stance: int = _operator.get("stance")
	var spread := 0.006 + _bloom + _operator.get_recoil() * 0.12
	if stance == 1:
		spread *= 0.7
	elif stance == 2:
		spread *= 0.45
	if _operator.get("is_sprinting"):
		spread *= 2.2
	var fired_direction := direction.normalized().rotated(randf_range(-spread, spread))
	var projectile := bullet_scene.instantiate()
	projectile.global_position = _operator.get_node("Muzzle").global_position
	projectile.set("direction", fired_direction)
	projectile.set("faction", "player")
	projectile.set("damage", base_damage * _damage_scale)
	projectile.set("speed", GameplayConfig.PLAYER_PROJECTILE_SPEED)
	projectile.set("shooter", _operator)
	_operator.get_tree().current_scene.add_child(projectile)
	_bloom = minf(_bloom + 0.035, 0.4)
	_operator.add_recoil(_bloom)
	var noise_radius := 70.0 if _role == 3 else 280.0
	GameRuntime.emit_noise(_operator.global_position, noise_radius)


func reload() -> void:
	if ammo >= magazine_size or reserve_ammo <= 0:
		return
	var amount := mini(magazine_size - ammo, reserve_ammo)
	ammo += amount
	reserve_ammo -= amount
	ammo_changed.emit(ammo, magazine_size)
	GameRuntime.emit_noise(_operator.global_position, 20.0 if _role == 3 else 85.0)


func throw_flashbang(direction: Vector2) -> void:
	if _operator == null or flashbang_scene == null or direction.length_squared() < 0.01:
		return
	var grenade := flashbang_scene.instantiate()
	grenade.global_position = _operator.global_position + direction.normalized() * 24.0
	_operator.get_tree().current_scene.add_child(grenade)
	grenade.call("launch", direction.normalized())
	GameRuntime.emit_noise(_operator.global_position, 100.0)


func set_role(role: int) -> void:
	_role = role
	var stats := RoleProfile.weapon_stats(role)
	_base_damage = float(stats["damage"])
	rounds_per_second = float(stats["fire_rate"])
	base_damage = _base_damage


func set_suppressive_fire(duration: float) -> void:
	_suppressive_timer = maxf(_suppressive_timer, duration)
	_damage_scale = 0.6


func is_suppressing() -> bool:
	return _suppressive_timer > 0.0


func set_auto_fire(enabled: bool) -> void:
	_auto_fire = enabled


func _auto_fire_target() -> Node2D:
	var facing := Vector2.RIGHT.rotated(_operator.global_rotation)
	for candidate in _operator.get_tree().get_nodes_in_group("enemy"):
		if not candidate is Node2D:
			continue
		var offset: Vector2 = candidate.global_position - _operator.global_position
		if offset.length() > 420.0 or facing.dot(offset.normalized()) < 0.985:
			continue
		var query := PhysicsRayQueryParameters2D.create(_operator.global_position, candidate.global_position, 1 | 2)
		query.exclude = [_operator.get_rid()]
		if _operator.get_world_2d().direct_space_state.intersect_ray(query).is_empty():
			return candidate
	return null
