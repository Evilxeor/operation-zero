extends Camera2D

@export var look_ahead := 90.0
@export var world_bounds := Rect2(-1500.0, -1000.0, 3000.0, 2000.0)


func _process(_delta: float) -> void:
	var mouse_offset := get_global_mouse_position() - global_position
	var target: Vector2 = get_parent().global_position + mouse_offset.limit_length(look_ahead) * 0.35
	global_position = target
	var half_view := get_viewport_rect().size * zoom * 0.5
	global_position.x = clampf(global_position.x, world_bounds.position.x + half_view.x, world_bounds.end.x - half_view.x)
	global_position.y = clampf(global_position.y, world_bounds.position.y + half_view.y, world_bounds.end.y - half_view.y)
