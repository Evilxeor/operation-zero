extends Node

signal noise_emitted(world_position: Vector2, radius: float)

const RIPPLE_SCENE: PackedScene = preload("res://scenes/ui/sound_ripple.tscn")


func emit_noise(world_position: Vector2, radius: float) -> void:
	noise_emitted.emit(world_position, radius)
	if radius <= 0.0:
		return
	var ripple := RIPPLE_SCENE.instantiate()
	ripple.global_position = world_position
	ripple.set("max_radius", radius)
	get_tree().current_scene.add_child(ripple)
