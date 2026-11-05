extends Node2D

@export var vest_color := Color(0.16, 0.22, 0.27, 1.0)
@export var accent_color := Color(0.15, 0.85, 1.0, 1.0)
@export var helmet_color := Color(0.24, 0.29, 0.32, 1.0)
@export var laser_color := Color(0.15, 0.85, 1.0, 0.6)
@export var show_laser := true


func _draw() -> void:
	draw_circle(Vector2.ZERO, 12.0, vest_color)
	draw_circle(Vector2(1.0, -1.0), 8.0, helmet_color)
	draw_circle(Vector2(4.0, -3.0), 3.0, accent_color)
	draw_line(Vector2(7.0, 2.0), Vector2(25.0, 2.0), Color(0.1, 0.12, 0.14, 1), 4.0)
	if show_laser:
		draw_line(Vector2(25.0, 2.0), Vector2(450.0, 2.0), laser_color, 1.0)
