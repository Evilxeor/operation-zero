extends Node2D

@export var map_size := Vector2(3000.0, 2000.0)
@export var cell_size := 64.0
@export var grid_color := Color(0.18, 0.23, 0.29, 0.35)
@export var major_grid_color := Color(0.24, 0.3, 0.37, 0.45)


func _draw() -> void:
	var half_size := map_size * 0.5
	var left := -half_size.x
	var right := half_size.x
	var top := -half_size.y
	var bottom := half_size.y
	var x := left
	while x <= right:
		var major := is_zero_approx(fposmod(x + half_size.x, cell_size * 5.0))
		draw_line(Vector2(x, top), Vector2(x, bottom), major_grid_color if major else grid_color, 1.0)
		x += cell_size
	var y := top
	while y <= bottom:
		var major := is_zero_approx(fposmod(y + half_size.y, cell_size * 5.0))
		draw_line(Vector2(left, y), Vector2(right, y), major_grid_color if major else grid_color, 1.0)
		y += cell_size
