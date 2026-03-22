extends "res://scripts/characters/move_executor.gd"
class_name DefaultMoveExecutor

func execute_move(player, move_data) -> void:
	if not is_instance_valid(player):
		return

	player.begin_attack_state()

	var startup_time: float = float(max(move_data.startup_frames, 0)) / 60.0
	if startup_time > 0.0:
		await player.get_tree().create_timer(startup_time).timeout
		if not is_instance_valid(player):
			return

	player.set_attack_hitbox_enabled(true)

	var active_time: float = float(max(move_data.active_frames, 1)) / 60.0
	await player.get_tree().create_timer(active_time).timeout
	if not is_instance_valid(player):
		return

	player.set_attack_hitbox_enabled(false)

	var endlag_time: float = float(max(move_data.endlag_frames, 0)) / 60.0
	if endlag_time > 0.0:
		await player.get_tree().create_timer(endlag_time).timeout
		if not is_instance_valid(player):
			return

	player.end_attack_state()
