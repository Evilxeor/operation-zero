extends Node

@export var interaction_range := 100.0
var _operator: Node2D


func _ready() -> void:
	_operator = get_parent() as Node2D


func interact_nearest() -> void:
	if _operator == null:
		return
	var target: Node2D
	var nearest := interaction_range
	for candidate in get_tree().get_nodes_in_group("interactable"):
		if not is_instance_valid(candidate) or not candidate is Node2D:
			continue
		var distance := _operator.global_position.distance_to(candidate.global_position)
		if distance < nearest:
			nearest = distance
			target = candidate
	if target != null:
		if target.has_method("interact"):
			target.call("interact", _operator)
		elif target.has_method("open"):
			target.call("open")
