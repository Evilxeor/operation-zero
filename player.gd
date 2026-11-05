extends CharacterBody2D

signal health_changed(current: float, maximum: float)
signal ammo_changed(current: int, maximum: int)
signal player_died

enum Stance { STAND, CROUCH, PRONE }
enum Role { POINTMAN, RECON, GUNNER, INFILTRATOR }

@export var max_health := 100.0
@export var field_of_view_degrees := 100.0
@export var vision_range := 620.0
@export var armor_plates := 3
@export var armor_per_plate := 35.0
@export var role: Role = Role.POINTMAN
var health := GameplayConfig.PLAYER_MAX_HEALTH
var movement_controller: Node
var weapon_controller: Node
var interaction_controller: Node
var mobile_move := Vector2.ZERO
var mobile_aim := Vector2.ZERO
var mobile_fire := false
var is_dead := false
var is_sprinting := false
var stance: Stance = Stance.STAND
var recon_active := false
var recon_timer := 0.0
var heartbeat_timer := 0.0
var ability_cooldown := 0.0
var _visibility_timer := 0.0
var _cover_timer := 0.0
var _in_cover := false
var _cover_normal := Vector2.ZERO
var _recoil := 0.0
var _aim_direction := Vector2.RIGHT


func _ready() -> void:
	add_to_group("player")
	health = max_health
	if max_health <= 0.0:
		max_health = GameplayConfig.PLAYER_MAX_HEALTH
	movement_controller = get_node_or_null("MovementController")
	weapon_controller = get_node_or_null("WeaponController")
	interaction_controller = get_node_or_null("InteractionController")
	var flashlight := get_node_or_null("Flashlight") as PointLight2D
	if flashlight != null:
		flashlight.texture = LightTextures.soft_radial
		flashlight.texture_scale = 4.0
	var ambient_light := get_node_or_null("AmbientLight") as PointLight2D
	if ambient_light != null:
		ambient_light.texture = LightTextures.soft_radial
		ambient_light.texture_scale = 1.2
		ambient_light.energy = 0.25
	health_changed.emit(health, max_health)
	if weapon_controller != null:
		weapon_controller.ammo_changed.connect(_on_ammo_changed)
		weapon_controller.set_role(role)
	$Flashlight.enabled = true
	$VisionCone.queue_redraw()


func _process(_delta: float) -> void:
	if is_dead:
		return
	var aim_direction := mobile_aim
	if aim_direction.length_squared() < 0.01:
		aim_direction = get_global_mouse_position() - global_position
	if aim_direction.length_squared() > 0.01:
		_aim_direction = aim_direction.normalized()
		var turn_rate := PlayerSystems.turn_rate_for_stance(stance)
		rotation = lerp_angle(rotation, _aim_direction.angle(), clampf(_delta * turn_rate, 0.0, 1.0))
	_visibility_timer -= _delta
	if _visibility_timer <= 0.0:
		_visibility_timer = 0.12
		_update_enemy_visibility()
	_cover_timer -= _delta
	if _cover_timer <= 0.0:
		_cover_timer = 0.12
		_update_cover_state()
	recon_timer = maxf(recon_timer - _delta, 0.0)
	if recon_timer <= 0.0:
		recon_active = false
	heartbeat_timer = maxf(heartbeat_timer - _delta, 0.0)
	ability_cooldown = maxf(ability_cooldown - _delta, 0.0)
	_recoil = maxf(_recoil - _delta * 1.8, 0.0)
	var mouse_fire := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and get_viewport().gui_get_hovered_control() == null
	if weapon_controller != null and (mouse_fire or mobile_fire):
		weapon_controller.fire(aim_direction)
	if Input.is_action_just_pressed("interact") and interaction_controller != null:
		interaction_controller.interact_nearest()
	if Input.is_action_just_pressed("reload") and weapon_controller != null:
		weapon_controller.reload()
	if Input.is_action_just_pressed("throw_flashbang") and weapon_controller != null:
		weapon_controller.throw_flashbang(aim_direction)
	if Input.is_action_just_pressed("crouch"):
		set_stance(Stance.CROUCH if stance != Stance.CROUCH else Stance.STAND)
	if Input.is_action_just_pressed("prone"):
		set_stance(Stance.PRONE if stance != Stance.PRONE else Stance.STAND)
	if Input.is_action_just_pressed("stand"):
		set_stance(Stance.STAND)
	if Input.is_action_just_pressed("ability"):
		use_ability()
	if Input.is_action_just_pressed("split_squad"):
		for member in get_tree().get_nodes_in_group("operative"):
			if member != self and member.has_method("set_command"):
				member.call("set_command", "split")
	for index in range(4):
		var role_action := "role_%d" % (index + 1)
		if Input.is_action_just_pressed(role_action):
			set_role(index)


func _update_enemy_visibility() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(enemy) or not enemy is Node2D:
			continue
		var delta := enemy.global_position - global_position
		var can_see := delta.length() <= get_effective_vision_range()
		if can_see:
			can_see = absf(wrapf(delta.angle() - global_rotation, -PI, PI)) <= deg_to_rad(get_effective_fov() * 0.5)
		if can_see:
			var query := PhysicsRayQueryParameters2D.create(global_position, enemy.global_position, 1 | 2)
			query.exclude = [get_rid()]
			can_see = get_world_2d().direct_space_state.intersect_ray(query).is_empty()
		if delta.length() <= 84.0:
			var proximity_query := PhysicsRayQueryParameters2D.create(global_position, enemy.global_position, 1 | 2)
			proximity_query.exclude = [get_rid()]
			can_see = get_world_2d().direct_space_state.intersect_ray(proximity_query).is_empty()
		if recon_active and delta.length() <= 560.0:
			can_see = true
		if role == Role.INFILTRATOR and heartbeat_timer > 0.0 and delta.length() <= 280.0:
			can_see = true
		enemy.set("player_spotted", can_see)


func _update_cover_state() -> void:
	var cover_state := PlayerSystems.cover_state_for(self)
	_in_cover = bool(cover_state["in_cover"])
	_cover_normal = cover_state["normal"]


func get_effective_fov() -> float:
	return PlayerSystems.effective_fov(field_of_view_degrees, role, stance)


func get_stance() -> int:
	return stance


func get_effective_vision_range() -> float:
	return PlayerSystems.effective_vision_range(vision_range, stance)


func set_stance(value: Stance) -> void:
	stance = value
	$VisionCone.queue_redraw()


func use_ability() -> void:
	PlayerAbilitySystem.use_ability(self)


func set_role(value: Role) -> void:
	role = value
	armor_plates = mini(armor_plates, RoleProfile.armor_cap(role))
	if weapon_controller != null:
		weapon_controller.set_role(role)
	$VisionCone.queue_redraw()


func take_damage(amount: float, _source: Node = null) -> void:
	PlayerDamageSystem.apply_damage(self, amount, _source)


func heal(amount: float) -> void:
	if is_dead or amount <= 0.0:
		return
	health = clampf(health + amount, 0.0, max_health)
	health_changed.emit(health, max_health)


func add_recoil(amount: float) -> void:
	_recoil = clampf(_recoil + amount, 0.0, 0.8)


func get_recoil() -> float:
	return _recoil


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var mark := get_global_mouse_position()
		for member in get_tree().get_nodes_in_group("operative"):
			if member != self and member.has_method("move_to_mark"):
				member.call("move_to_mark", mark)


func _on_ammo_changed(current: int, maximum: int) -> void:
	ammo_changed.emit(current, maximum)
