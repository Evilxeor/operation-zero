extends Control

@export var indicator_color := Color(0.25, 0.85, 1.0, 0.9)
var _strength := 0.0


func _ready() -> void:
	var sound_manager := get_tree().root.get_node_or_null("/root/SoundManager")
	if sound_manager != null and sound_manager.has_signal("noise_emitted"):
		sound_manager.noise_emitted.connect(_on_noise)


func _on_noise(_world_position: Vector2, _radius: float) -> void:
	_strength = 1.0
	visible = true


func _process(delta: float) -> void:
	_strength = maxf(_strength - delta * 0.7, 0.0)
	queue_redraw()
	if _strength <= 0.0:
		visible = false


func _draw() -> void:
	draw_arc(size * 0.5, 8.0 + _strength * 10.0, 0.0, TAU, 24, indicator_color * _strength, 2.0)
