extends Node

# 2-Player Input Handler
# Player 1: WASD + T (attack)
# Player 2: Arrow Keys + P (attack)

func get_player1_input():
	var input = {
		"left": Input.is_action_pressed("ui_left_p1"),
		"right": Input.is_action_pressed("ui_right_p1"),
		"jump": Input.is_action_just_pressed("ui_up_p1"),
		"attack": Input.is_action_just_pressed("attack_p1")
	}
	return input

func get_player2_input():
	var input = {
		"left": Input.is_action_pressed("ui_left_p2") or Input.is_action_pressed("ui_left"),
		"right": Input.is_action_pressed("ui_right_p2") or Input.is_action_pressed("ui_right"),
		"jump": Input.is_action_just_pressed("ui_up_p2") or Input.is_action_just_pressed("ui_up"),
		"attack": Input.is_action_just_pressed("attack_p2")
	}
	return input
