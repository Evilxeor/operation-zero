extends StaticBody2D

@export var wall_size := Vector2(128.0, 24.0):
	set(value):
		wall_size = value
		_update_wall()
@export var wall_color := Color(0.19, 0.23, 0.27, 1.0)
@export var edge_color := Color(0.36, 0.43, 0.48, 1.0)
@export var is_soft_cover := false


func _ready() -> void:
	add_to_group("world_wall")
	if is_soft_cover:
		add_to_group("soft_cover")
	_update_wall()


func _update_wall() -> void:
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision == null:
		return
	var rectangle := collision.shape as RectangleShape2D
	if rectangle == null:
		rectangle = RectangleShape2D.new()
		collision.shape = rectangle
	else:
		collision.shape = rectangle.duplicate()
	(collision.shape as RectangleShape2D).size = wall_size
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(-wall_size * 0.5, wall_size)
	draw_rect(rect, wall_color)
	draw_rect(rect, edge_color, false, 2.0)
	var half := wall_size * 0.5
	draw_line(Vector2(-half.x + 5.0, 0.0), Vector2(half.x - 5.0, 0.0), edge_color.darkened(0.25), 1.0)
