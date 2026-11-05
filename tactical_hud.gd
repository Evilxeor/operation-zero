extends CanvasLayer

var _player: Node
var _squadmate: Node
var _nearby_interactable: Node
var _fire_touch_held := false

@onready var _objective_label: Label = $ObjectiveBanner/ObjectiveLabel
@onready var _status_label: Label = $SquadStatusLabel
@onready var _comms_panel: Control = $RadioCommsBox
@onready var _comms_text: Label = $RadioCommsBox/CommsText
@onready var _action_panel: Control = $DoorActionsPanel
@onready var _squad_bar: Control = $SquadBar
@onready var _briefing_modal: Control = $BriefingModal


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")
	_squadmate = get_tree().get_first_node_in_group("operative")
	_connect_controls()
	MissionManager.enemy_count_changed.connect(_on_enemy_count_changed)
	MissionManager.mission_won.connect(_on_mission_won)
	MissionManager.mission_failed.connect(_on_mission_failed)
	MissionManager.round_time_changed.connect(_on_round_time_changed)
	if _player != null:
		_player.health_changed.connect(_on_health_changed)
		_player.ammo_changed.connect(_on_ammo_changed)
		_on_health_changed(_player.health, _player.max_health)
		var weapon := _player.get_node_or_null("WeaponController")
		if weapon != null:
			_on_ammo_changed(weapon.ammo, weapon.magazine_size)
	var touch_controls := DisplayServer.is_touchscreen_available()
	$LeftStick.visible = touch_controls
	$RightStick.visible = touch_controls
	$FireButton.visible = touch_controls
	$DoorActionsPanel.visible = false
	$BriefingModal.visible = true
	$BriefingModal/Panel/ModeButton.text = "MODE: EXTRACTION" if MissionManager.mode == 0 else "MODE: ELIMINATION"
	$BriefingModal/Panel/BriefingText.text = "Clear all hostiles, then reach either extraction zone." if MissionManager.mode == 0 else "Eliminate all hostiles before the 3-minute round expires."
	_on_enemy_count_changed(MissionManager.enemies_remaining)


func _process(_delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var left_stick := $LeftStick
	var right_stick := $RightStick
	_player.mobile_move = left_stick.direction
	_player.mobile_aim = right_stick.direction.rotated(_player.get_node("Camera2D").global_rotation)
	_player.mobile_fire = _fire_touch_held
	_nearby_interactable = _find_nearby_interactable()
	_action_panel.visible = _nearby_interactable != null
	if _nearby_interactable != null:
		$DoorActionsPanel/BtnKick.visible = _nearby_interactable.has_method("kick")
		$DoorActionsPanel/BtnOpen.visible = _nearby_interactable.has_method("open")
		$DoorActionsPanel/BtnCharge.visible = _nearby_interactable.has_method("charge") and _nearby_interactable.has_method("open")
		$DoorActionsPanel/BtnWallCharge.visible = _nearby_interactable.has_method("charge") and not _nearby_interactable.has_method("open")
	_update_operator_status()


func _connect_controls() -> void:
	$DoorActionsPanel/BtnKick.pressed.connect(_on_door_action.bind("kick"))
	$DoorActionsPanel/BtnOpen.pressed.connect(_on_door_action.bind("open"))
	$DoorActionsPanel/BtnCharge.pressed.connect(_on_door_action.bind("charge"))
	$DoorActionsPanel/BtnWallCharge.pressed.connect(_on_door_action.bind("wall_charge"))
	$SquadMenuButton.pressed.connect(func() -> void: _squad_bar.visible = not _squad_bar.visible)
	$SquadBar/BtnStack.pressed.connect(_on_squad_command.bind("regroup", "BRAVO: REGROUPING ON LEAD"))
	$SquadBar/BtnMoveBravo.pressed.connect(_on_squad_command.bind("move", "BRAVO: MOVING TO MARK"))
	$SquadBar/BtnBreach.pressed.connect(_on_squad_command.bind("breach", "BRAVO: BREACH AND CLEAR"))
	$SquadBar/BtnCover.pressed.connect(_on_squad_command.bind("cover", "BRAVO: COVERING REAR"))
	$SquadBar/BtnHoldFire.pressed.connect(_on_squad_command.bind("hold_fire", "BRAVO: HOLDING FIRE"))
	$SquadBar/BtnStance.pressed.connect(_on_squad_command.bind("free", "BRAVO: WEAPONS FREE"))
	$SquadBar/BtnSplit.pressed.connect(_on_squad_command.bind("split", "BRAVO: SPLIT ELEMENTS"))
	$SquadBar/BtnTargetAlpha.pressed.connect(_on_squad_command.bind("target", "BRAVO: ENGAGING TARGET ALPHA"))
	$SquadBar/BtnHold.pressed.connect(_on_squad_command.bind("hold", "BRAVO: HOLDING POSITION"))
	$RightActions/FlashbangBtn.pressed.connect(_on_throw_flashbang)
	$RightActions/ReloadBtn.pressed.connect(_on_reload)
	$RightActions/StanceBtn.pressed.connect(_cycle_stance)
	$RightActions/AbilityBtn.pressed.connect(_on_use_ability)
	$RightActions/AutoFireBtn.toggled.connect(_on_auto_fire_toggled)
	$RoleButton.pressed.connect(_cycle_role)
	$FireButton.button_down.connect(func() -> void: _fire_touch_held = true)
	$FireButton.button_up.connect(func() -> void: _fire_touch_held = false)
	$BriefingModal/Panel/BtnStartMission.pressed.connect(_start_mission)
	$BriefingModal/Panel/ModeButton.pressed.connect(_cycle_mode)
	$VictoryModal/Panel/BtnRestartWin.pressed.connect(_restart_mission)
	$DefeatModal/Panel/BtnRestartLose.pressed.connect(_restart_mission)
	$RadioCalloutTimer.timeout.connect(func() -> void: _comms_panel.hide())
	$"../RoundTimer".timeout.connect(MissionManager.tick_round)


func _find_nearby_interactable() -> Node:
	var nearest: Node
	var nearest_distance := 115.0
	for candidate in get_tree().get_nodes_in_group("interactable"):
		if not is_instance_valid(candidate) or not candidate is Node2D:
			continue
		var distance: float = _player.global_position.distance_to(candidate.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = candidate
	return nearest


func _on_door_action(action: String) -> void:
	if _nearby_interactable == null or not is_instance_valid(_nearby_interactable):
		return
	match action:
		"kick":
			if _nearby_interactable.has_method("kick"):
				_nearby_interactable.call("kick", _player)
			elif _nearby_interactable.has_method("charge"):
				_nearby_interactable.call("charge")
		"open":
			if _nearby_interactable.has_method("interact"):
				_nearby_interactable.call("interact", _player)
			elif _nearby_interactable.has_method("open"):
				_nearby_interactable.call("open", _player)
		"charge":
			if _nearby_interactable.has_method("charge"):
				_nearby_interactable.call("charge")
		"wall_charge":
			if _nearby_interactable.has_method("charge"):
				_nearby_interactable.call("charge")


func _on_squad_command(command: String, status: String) -> void:
	for member in get_tree().get_nodes_in_group("operative"):
		if member != _player and member.has_method("set_command"):
			member.call("set_command", command)
	_status_label.text = status
	_comms_text.text = status
	_comms_panel.show()
	$RadioCalloutTimer.start()


func _on_throw_flashbang() -> void:
	if _player != null and is_instance_valid(_player):
		var direction: Vector2 = _player.get_global_mouse_position() - _player.global_position
		if direction.length_squared() < 0.01:
			direction = Vector2.RIGHT.rotated(_player.global_rotation)
		_player.weapon_controller.throw_flashbang(direction)


func _on_reload() -> void:
	if _player != null and is_instance_valid(_player):
		_player.weapon_controller.reload()


func _on_use_ability() -> void:
	if _player != null and is_instance_valid(_player):
		_player.use_ability()


func _on_auto_fire_toggled(enabled: bool) -> void:
	if _player != null and is_instance_valid(_player):
		_player.weapon_controller.set_auto_fire(enabled)


func _cycle_stance() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	_player.set_stance((_player.stance + 1) % 3)


func _cycle_role() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	_player.set_role((_player.role + 1) % 4)


func _update_operator_status() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var role_names := ["POINTMAN", "RECON", "GUNNER", "INFILTRATOR"]
	var stance_names := ["STAND", "CROUCH", "PRONE"]
	$RoleStatusLabel.text = "ROLE: %s | STANCE: %s | PLATES: %d | COVER: %s" % [
		role_names[_player.role], stance_names[_player.stance], _player.armor_plates, "YES" if _player._in_cover else "NO"
	]
	$RoleButton.text = "ROLE: %s [1-4]" % role_names[_player.role]
	$RightActions/StanceBtn.text = "STANCE: %s" % stance_names[_player.stance]
	$RightActions/AbilityBtn.text = "%s [F] %s" % [
		RoleProfile.ability_name(_player.role),
		"%.0fs" % _player.ability_cooldown if _player.ability_cooldown > 0.0 else ""
	]


func _on_health_changed(current: float, maximum: float) -> void:
	$TopLeft/HealthBar.max_value = maximum
	$TopLeft/HealthBar.value = current


func _on_ammo_changed(current: int, maximum: int) -> void:
	$TopLeft/AmmoLabel.text = "AMMO: %d / %d" % [current, maximum]


func _on_enemy_count_changed(remaining: int) -> void:
	_objective_label.text = "TARGETS: %d REMAINING" % remaining
	if remaining == 0:
		_objective_label.text = "ALL HOSTILES DOWN - REACH EXTRACTION" if MissionManager.mode == 0 else "HOSTILES ELIMINATED"


func _start_mission() -> void:
	_briefing_modal.hide()
	get_parent().call("start_mission")
	$"../RoundTimer".start()
	MissionManager.start_round(int($"../RoundTimer".wait_time))


func _cycle_mode() -> void:
	var next_mode := (MissionManager.mode + 1) % 2
	MissionManager.set_mode(next_mode)
	$BriefingModal/Panel/ModeButton.text = "MODE: EXTRACTION" if next_mode == 0 else "MODE: ELIMINATION"
	$BriefingModal/Panel/BriefingText.text = "Clear all hostiles, then reach either extraction zone." if next_mode == 0 else "Eliminate all hostiles before the 3-minute round expires."


func _on_round_time_changed(seconds_remaining: int) -> void:
	var minutes := seconds_remaining / 60
	var seconds := seconds_remaining % 60
	$RoundStatusLabel.text = "ROUND %02d:%02d" % [minutes, seconds]


func _on_mission_won() -> void:
	$"../RoundTimer".stop()
	$VictoryModal.show()
	_action_panel.hide()


func _on_mission_failed() -> void:
	$"../RoundTimer".stop()
	$DefeatModal.show()
	_action_panel.hide()


func _restart_mission() -> void:
	get_tree().reload_current_scene()
