extends Control

@export var handle_color := Color(0.2, 0.85, 1.0, 0.75)
@export var border_color := Color(0.2, 0.75, 0.9, 0.45)

var direction := Vector2.ZERO
var _finger_index := -1
var _knob_offset := Vector2.ZERO
var _radius := 72.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_radius = minf(size.x, size.y) * 0.42


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _finger_index == -1:
			_finger_index = event.index
			_update_stick(event.position)
		elif not event.pressed and event.index == _finger_index:
			_reset_stick()
	elif event is InputEventScreenDrag and event.index == _finger_index:
		_update_stick(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_finger_index = 0
			_update_stick(event.position)
		else:
			_reset_stick()
	elif event is InputEventMouseMotion and _finger_index == 0 and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_update_stick(event.position)


func _update_stick(pointer_position: Vector2) -> void:
	_knob_offset = (pointer_position - size * 0.5).limit_length(_radius)
	direction = _knob_offset / maxf(_radius, 1.0)
	queue_redraw()


func _reset_stick() -> void:
	_finger_index = -1
	_knob_offset = Vector2.ZERO
	direction = Vector2.ZERO
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, _radius, Color(0.03, 0.08, 0.12, 0.32))
	draw_arc(center, _radius, 0.0, TAU, 48, border_color, 2.0)
	draw_circle(center + _knob_offset, _radius * 0.35, handle_color)
