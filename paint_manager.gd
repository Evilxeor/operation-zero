extends Node

const PAINT_SPLAT_SCENE: PackedScene = preload("res://scenes/effects/paint_splat.tscn")


func spawn_splat(world_position: Vector2, color: Color) -> void:
	var splat := PAINT_SPLAT_SCENE.instantiate()
	splat.global_position = world_position
	splat.set("splat_color", color)
	get_tree().current_scene.add_child(splat)
