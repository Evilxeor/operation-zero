extends CharacterBody2D

@export var max_health := 60.0
@export var move_speed := 80.0
@export var detection_range := 480.0
@export var fire_interval := 1.1
@export var armor_plates := 1
@export var field_of_view_degrees := 110.0
@export var cover_speed_multiplier := 0.55
@export var bullet_scene: PackedScene = preload("res://scenes/objects/bullet.tscn")

var health := GameplayConfig.ENEMY_MAX_HEALTH
var _target: Node2D
var _fire_timer := 0.0
var _stun_timer := 0.0
var _dead := false
var player_spotted := false
var _last_known_position := Vector2.ZERO
var _suppressed_timer := 0.0


func _ready() -> void:
	add_to_group("enemy")
	health = max_health
	if max_health <= 0.0:
		max_health = GameplayConfig.ENEMY_MAX_HEALTH
	_target = GameRuntime.get_player()
	var sound_manager := get_tree().root.get_node_or_null("/root/SoundManager")
	if sound_manager != null and sound_manager.has_signal("noise_emitted"):
		sound_manager.noise_emitted.connect(_on_noise_emitted)


func _physics_process(delta: float) -> void:
	if _dead:
		return
	_fire_timer = maxf(_fire_timer - delta, 0.0)
	_stun_timer = maxf(_stun_timer - delta, 0.0)
	_suppressed_timer = maxf(_suppressed_timer - delta, 0.0)
	if _target == null or not is_instance_valid(_target):
		_target = GameRuntime.get_player()
	velocity = Vector2.ZERO
	if _target == null or _stun_timer > 0.0:
		move_and_slide()
		return
	var offset := _target.global_position - global_position
	var target_visible := false
	var effective_detection_range := EnemyAISystems.effective_detection_range(self, _target)
	if offset.length() <= effective_detection_range:
		if EnemyAISystems.target_visible(self, _target):
			target_visible = true
			_last_known_position = _target.global_position
			EnemyAISystems.rotation_toward_target(self, _target.global_position)
			if offset.length() > 180.0:
				velocity = offset.normalized() * move_speed * (cover_speed_multiplier if _suppressed_timer > 0.0 else 1.0)
			elif _fire_timer == 0.0:
				_fire_at_target(offset)
	if not target_visible and _last_known_position != Vector2.ZERO:
		var investigate := _last_known_position - global_position
		if investigate.length() > 32.0:
			EnemyAISystems.rotation_toward_target(self, _last_known_position)
			velocity = investigate.normalized() * move_speed * 0.7
		else:
			_last_known_position = Vector2.ZERO
	move_and_slide()
	visible = player_spotted or EnemyAISystems.is_visible_to_squad(self)


func _fire_at_target(direction: Vector2) -> void:
	_fire_timer = fire_interval
	var bullet := bullet_scene.instantiate()
	bullet.global_position = get_node("Muzzle").global_position
	bullet.set("direction", direction.normalized())
	bullet.set("faction", "enemy")
	bullet.set("speed", GameplayConfig.ENEMY_PROJECTILE_SPEED)
	bullet.set("shooter", self)
	get_tree().current_scene.add_child(bullet)
	GameRuntime.emit_noise(global_position, 320.0)


func take_damage(amount: float, _source: Node = null) -> void:
	if _dead:
		return
	var final_damage := amount
	if armor_plates > 0:
		final_damage *= 0.65
		armor_plates -= 1
	health -= final_damage
	if health <= 0.0:
		_die()


func stun(duration: float) -> void:
	_stun_timer = maxf(_stun_timer, duration)


func apply_suppression(duration: float) -> void:
	_suppressed_timer = maxf(_suppressed_timer, duration)


func _on_noise_emitted(source: Vector2, radius: float) -> void:
	if EnemyAISystems.can_hear_noise(self, source, radius):
		_last_known_position = source


func _is_visible_to_squad() -> bool:
	return EnemyAISystems.is_visible_to_squad(self)


func _die() -> void:
	_dead = true
	MissionManager.enemy_eliminated()
	GameRuntime.spawn_splat(global_position, Color(0.55, 0.12, 0.14, 0.85))
	queue_free()
