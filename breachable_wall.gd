extends StaticBody2D

@export var wall_size := Vector2(96.0, 24.0):
	set(value):
		wall_size = value
		_update_wall()
@export var blast_radius := 180.0
@export var blast_damage := 100.0
var _breached := false


func _ready() -> void:
	add_to_group("interactable")
	add_to_group("world_wall")
	_update_wall()


func interact(_actor: Node = null) -> void:
	charge()


func charge() -> void:
	if _breached:
		return
	_breached = true
	GameRuntime.emit_noise(global_position, 700.0)
	await get_tree().create_timer(1.0).timeout
	if not is_inside_tree():
		return
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy is Node2D and global_position.distance_to(enemy.global_position) <= blast_radius:
			enemy.call("take_damage", blast_damage, self)
	for operative in get_tree().get_nodes_in_group("player"):
		if operative is Node2D and global_position.distance_to(operative.global_position) <= blast_radius:
			operative.call("take_damage", blast_damage, self)
	GameRuntime.spawn_splat(global_position, Color(0.42, 0.35, 0.28, 0.9))
	queue_free()


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
	var occluder := get_node_or_null("LightOccluder2D") as LightOccluder2D
	if occluder != null and occluder.occluder is OccluderPolygon2D:
		var polygon := (occluder.occluder as OccluderPolygon2D).duplicate()
		var half := wall_size * 0.5
		polygon.polygon = PackedVector2Array([
			Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
			Vector2(half.x, half.y), Vector2(-half.x, half.y)
		])
		occluder.occluder = polygon
	queue_redraw()
