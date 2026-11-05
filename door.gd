extends StaticBody2D

signal door_state_changed(is_open: bool)

@export var is_locked := false
var is_open := false
var _busy := false


func _ready() -> void:
	add_to_group("interactable")


func interact(actor: Node = null) -> void:
	if is_locked and actor != null and actor.get("role") == 3:
		_silent_pick()
		return
	open(actor)


func open(_actor: Node = null) -> void:
	if _busy or is_open or is_locked:
		return
	_set_open(true)


func kick(actor: Node = null) -> void:
	if _busy or is_open:
		return
	if is_locked and actor != null and actor.get("role") == 0:
	GameRuntime.emit_noise(global_position, 380.0)
	else:
	GameRuntime.emit_noise(global_position, 460.0)
	_set_open(true)


func charge() -> void:
	if _busy or is_open:
		return
	_busy = true
	GameRuntime.emit_noise(global_position, 650.0)
	await get_tree().create_timer(0.8).timeout
	if is_inside_tree():
		is_locked = false
		_set_open(true)
	_busy = false


func _silent_pick() -> void:
	if _busy or is_open:
		return
	_busy = true
	await get_tree().create_timer(1.5).timeout
	if is_inside_tree():
		is_locked = false
		_set_open(true)
	_busy = false


func _set_open(value: bool) -> void:
	is_open = value
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision != null:
		collision.set_deferred("disabled", is_open)
	var occluder := get_node_or_null("LightOccluder2D") as LightOccluder2D
	if occluder != null:
		occluder.visible = not is_open
	door_state_changed.emit(is_open)
