extends Node

@export var move_speed := 190.0
@export var crouch_speed_multiplier := 0.62
@export var prone_speed_multiplier := 0.3
@export var sprint_speed_multiplier := 1.55
var operator: CharacterBody2D
var _sprint_noise_timer := 0.0
var _footstep_timer := 0.0


func _ready() -> void:
	operator = get_parent() as CharacterBody2D


func _physics_process(_delta: float) -> void:
	if operator == null or operator.get("is_dead") == true:
		return
	var movement := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var keyboard := Vector2(
		float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
		float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
	).normalized()
	if keyboard.length_squared() > movement.length_squared():
		movement = keyboard
	var mobile: Vector2 = operator.get("mobile_move")
	if mobile.length_squared() > movement.length_squared():
		movement = mobile
	var speed := move_speed
	var stance: int = operator.get("stance")
	if stance == 1:
		speed *= crouch_speed_multiplier
	elif stance == 2:
		speed *= prone_speed_multiplier
	var sprinting := Input.is_action_pressed("sprint") and movement.length_squared() > 0.1 and stance == 0
	operator.is_sprinting = sprinting
	if sprinting:
		speed *= sprint_speed_multiplier
		_sprint_noise_timer -= _delta
		if _sprint_noise_timer <= 0.0:
			_sprint_noise_timer = 0.45
			var radius := 110.0 if operator.role == 3 else 300.0
			GameRuntime.emit_noise(operator.global_position, radius)
	elif movement.length_squared() > 0.1 and stance == 0:
		_footstep_timer -= _delta
		if _footstep_timer <= 0.0:
			_footstep_timer = 0.72
			GameRuntime.emit_noise(operator.global_position, 65.0 if operator.role == 3 else 90.0)
	else:
		_footstep_timer = 0.0
	operator.velocity = movement * speed
	operator.move_and_slide()
