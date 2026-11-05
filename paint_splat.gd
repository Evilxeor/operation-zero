extends Node2D

@export var splat_color := Color(0.75, 0.15, 0.16, 0.85)
@export var radius := 14.0
var _points := PackedVector2Array()


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for index in range(9):
		var angle := TAU * float(index) / 9.0
		var distance := radius * rng.randf_range(0.65, 1.0)
		_points.append(Vector2(cos(angle), sin(angle)) * distance)
	queue_redraw()
	var timer := get_tree().create_timer(18.0)
	timer.timeout.connect(queue_free)


func _draw() -> void:
	if _points.size() >= 3:
		draw_colored_polygon(_points, splat_color)
