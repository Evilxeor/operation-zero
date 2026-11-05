extends Node2D

func _draw() -> void:
	var operator := get_parent()
	var half_angle := deg_to_rad(operator.get_effective_fov() * 0.5)
	var vision_range: float = operator.get_effective_vision_range()
	var points := PackedVector2Array([Vector2.ZERO])
	for index in range(41):
		var angle := -half_angle + (2.0 * half_angle * float(index) / 40.0)
		points.append(Vector2.RIGHT.rotated(angle) * vision_range)
	draw_colored_polygon(points, Color(0.25, 0.72, 0.95, 0.055))
	draw_line(Vector2.ZERO, points[1], Color(0.3, 0.8, 1.0, 0.3), 1.0)
	draw_line(Vector2.ZERO, points[points.size() - 1], Color(0.3, 0.8, 1.0, 0.3), 1.0)
