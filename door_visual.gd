extends Node2D

@export var door_width := 72.0
@export var closed_color := Color(0.36, 0.26, 0.17, 1.0)
@export var open_color := Color(0.24, 0.18, 0.15, 0.65)

var _door: Node


func _ready() -> void:
	_door = get_parent()
	if _door.has_signal("door_state_changed"):
		_door.door_state_changed.connect(_on_door_state_changed)


func _draw() -> void:
	if _door != null and _door.get("is_open") == true:
		draw_line(Vector2(0, 0), Vector2(door_width, 0), open_color, 4.0)
	else:
		draw_rect(Rect2(0, -6, door_width, 12), closed_color)
		draw_line(Vector2(8, -4), Vector2(door_width - 8, -4), closed_color.lightened(0.25), 1.5)


func _on_door_state_changed(_is_open: bool) -> void:
	queue_redraw()
