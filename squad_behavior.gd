class_name SquadBehavior
extends RefCounted

static func get_default_destination(squad_index: int, player_position: Vector2, facing: float) -> Vector2:
	var side := float(squad_index - 2)
	return player_position + Vector2(-54.0, side * 34.0).rotated(facing)


static func get_split_destination(player_position: Vector2, facing: float, squad_index: int) -> Vector2:
	var flank := Vector2.RIGHT.rotated(facing)
	var side := -1.0 if squad_index == 1 else 1.0
	return player_position + flank * 150.0 + flank.orthogonal() * side * 150.0


static func get_follow_destination(player_position: Vector2, squad_index: int, facing: float, offset: Vector2 = Vector2.ZERO) -> Vector2:
	var side := float(squad_index - 2)
	return player_position + Vector2(-54.0, side * 34.0).rotated(facing) + offset
