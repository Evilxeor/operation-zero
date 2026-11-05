extends Area2D

signal extraction_available
var _player_inside := false
var _completed := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	MissionManager.enemy_count_changed.connect(_on_enemy_count_changed)
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 42.0, Color(0.12, 0.8, 0.5, 0.12))
	draw_arc(Vector2.ZERO, 42.0, 0.0, TAU, 48, Color(0.2, 1.0, 0.65, 0.85), 3.0)
	draw_arc(Vector2.ZERO, 31.0, 0.0, TAU, 48, Color(0.2, 1.0, 0.65, 0.5), 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(-30.0, 4.0), "EXFIL", HORIZONTAL_ALIGNMENT_CENTER, 60.0, 12, Color(0.6, 1.0, 0.8, 1.0))


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		_try_extract()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false


func _on_enemy_count_changed(_remaining: int) -> void:
	_try_extract()


func _try_extract() -> void:
	if MissionManager.mode == 1:
		return
	if _player_inside and not _completed and MissionManager.can_extract():
		_completed = true
		extraction_available.emit()
		MissionManager.complete_mission()
