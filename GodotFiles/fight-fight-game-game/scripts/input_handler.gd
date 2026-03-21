extends Node

# 2-Player Input Handler
# Player 1: Arrow Keys + Q (attack)
# Player 2: WASD + Enter (attack)

func get_player1_input():
	var input = {
		"left": Input.is_action_pressed("ui_left"),
		"right": Input.is_action_pressed("ui_right"),
		"jump": Input.is_action_just_pressed("ui_up"),
		"attack": Input.is_action_just_pressed("attack_p1")
	}
	return input

func get_player2_input():
	var input = {
		"left": Input.is_action_pressed("ui_left_p2"),
		"right": Input.is_action_pressed("ui_right_p2"),
		"jump": Input.is_action_just_pressed("ui_up_p2"),
		"attack": Input.is_action_just_pressed("attack_p2")
	}
	return input
