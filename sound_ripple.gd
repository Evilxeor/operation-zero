extends Node2D

@export var max_radius := 300.0
@export var duration := 0.65
var _age := 0.0


func _process(delta: float) -> void:
	_age += delta
	queue_redraw()
	if _age >= duration:
		queue_free()


func _draw() -> void:
	var progress := clampf(_age / duration, 0.0, 1.0)
	draw_arc(Vector2.ZERO, max_radius * progress, 0.0, TAU, 48, Color(0.25, 0.85, 1.0, 0.55 * (1.0 - progress)), 2.0)
