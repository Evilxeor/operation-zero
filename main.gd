extends Node2D

var mission_started := false

func _enter_tree() -> void:
	_add_key_action("move_up", KEY_W)
	_add_key_action("move_down", KEY_S)
	_add_key_action("move_left", KEY_A)
	_add_key_action("move_right", KEY_D)
	_add_key_action("interact", KEY_E)
	_add_key_action("reload", KEY_R)
	_add_key_action("throw_flashbang", KEY_G)
	_add_key_action("crouch", KEY_C)
	_add_key_action("prone", KEY_X)
	_add_key_action("stand", KEY_V)
	_add_key_action("ability", KEY_F)
	_add_key_action("split_squad", KEY_Z)
	_add_key_action("sprint", KEY_SHIFT)
	for index in range(4):
		_add_key_action("role_%d" % (index + 1), KEY_1 + index)


func _ready() -> void:
	print("Operation Zero project: ", ProjectSettings.globalize_path("res://"))
	var enemies := GameRuntime.get_enemy_nodes()
	MissionManager.begin_mission(enemies.size())
	var player := get_node_or_null("Operatives/Player")
	if player != null:
		player.add_to_group("player")
		player.add_to_group("operative")
	for operative in GameRuntime.get_operative_nodes():
		if operative != player:
			operative.process_mode = Node.PROCESS_MODE_DISABLED
	for enemy in enemies:
		if enemy is Node:
			enemy.process_mode = Node.PROCESS_MODE_DISABLED


func start_mission() -> void:
	if mission_started:
		return
	mission_started = true
	for operative in GameRuntime.get_operative_nodes():
		if operative is Node:
			operative.process_mode = Node.PROCESS_MODE_INHERIT
	for enemy in GameRuntime.get_enemy_nodes():
		if enemy is Node:
			enemy.process_mode = Node.PROCESS_MODE_INHERIT


func _add_key_action(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	if InputMap.action_get_events(action_name).is_empty():
		var event := InputEventKey.new()
		event.physical_keycode = keycode
		InputMap.action_add_event(action_name, event)
