extends Node2D

@export var fill_color := Color(0.31, 0.27, 0.23, 1.0)
@export var edge_color := Color(0.78, 0.53, 0.22, 1.0)


func _draw() -> void:
	var wall := get_parent()
	var size: Vector2 = wall.get("wall_size")
	var rect := Rect2(-size * 0.5, size)
	draw_rect(rect, fill_color)
	draw_rect(rect, edge_color, false, 2.0)
	for x in range(-int(size.x * 0.4), int(size.x * 0.5), 14):
		draw_line(Vector2(x, -size.y * 0.5), Vector2(x + 8, size.y * 0.5), edge_color.darkened(0.35), 1.0)
