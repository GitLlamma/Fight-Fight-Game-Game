extends Node

class_name GameManager

signal player_won(player_number: int)
signal health_changed(player_number: int, health: float)

var player1: Player
var player2: Player
var game_over := false

func _ready():
	# Get player references from scene
	player1 = get_node("Arena/Player1")
	player2 = get_node("Arena/Player2")
	
	if player1:
		player1.set_player_number(1)
	if player2:
		player2.set_player_number(2)

func _process(_delta):
	if game_over:
		return

	# Check if either player has been defeated
	if is_instance_valid(player1) and player1.health <= 0:
		on_player_defeated(1)
	elif is_instance_valid(player2) and player2.health <= 0:
		on_player_defeated(2)

func on_player_defeated(player_number: int):
	if game_over:
		return

	game_over = true
	var winner = 3 - player_number  # If player 1 lost, player 2 won
	player_won.emit(winner)
	print("Player %d wins!" % winner)

func reset_game():
	print("Resetting game...")
	# TODO: Reset player positions, health, etc.
