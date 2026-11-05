extends Node

enum Mode { EXTRACTION, ELIMINATION }
enum MissionState { BRIEFING, ACTIVE, VICTORY, DEFEAT }

signal enemy_count_changed(remaining: int)
signal mission_won
signal mission_failed
signal round_time_changed(seconds_remaining: int)

var enemies_remaining := 0
var mission_finished := false
var round_seconds_remaining := GameplayConfig.ROUND_DURATION_SECONDS
var mission_state: MissionState = MissionState.BRIEFING
var mode: Mode = Mode.EXTRACTION


func begin_mission(enemy_count: int) -> void:
	mission_finished = false
	enemies_remaining = maxi(enemy_count, 0)
	round_seconds_remaining = GameplayConfig.ROUND_DURATION_SECONDS
	mission_state = MissionState.BRIEFING
	enemy_count_changed.emit(enemies_remaining)


func enemy_eliminated() -> void:
	if mission_finished:
		return
	enemies_remaining = maxi(enemies_remaining - 1, 0)
	enemy_count_changed.emit(enemies_remaining)
	if mission_state == MissionState.ACTIVE and enemies_remaining == 0 and mode == Mode.ELIMINATION:
		complete_mission()


func set_mode(value: Mode) -> void:
	mode = value
	if mission_state == MissionState.BRIEFING:
		enemy_count_changed.emit(enemies_remaining)


func can_extract() -> bool:
	return mission_state == MissionState.ACTIVE and enemies_remaining == 0 and not mission_finished


func complete_mission() -> void:
	if mission_finished:
		return
	mission_finished = true
	mission_state = MissionState.VICTORY
	mission_won.emit()


func fail_mission() -> void:
	if mission_finished:
		return
	mission_finished = true
	mission_state = MissionState.DEFEAT
	mission_failed.emit()


func start_round(seconds: int = GameplayConfig.ROUND_DURATION_SECONDS) -> void:
	mission_state = MissionState.ACTIVE
	round_seconds_remaining = maxi(seconds, GameplayConfig.ROUND_SECONDS_MINIMUM)
	round_time_changed.emit(round_seconds_remaining)
	if mode == Mode.ELIMINATION and enemies_remaining == 0:
		complete_mission()


func tick_round() -> void:
	if mission_finished or mission_state != MissionState.ACTIVE:
		return
	round_seconds_remaining = maxi(round_seconds_remaining - 1, 0)
	round_time_changed.emit(round_seconds_remaining)
	if round_seconds_remaining == 0:
		fail_mission()
