extends Node

class_name GameManager

signal player_won(player_number: int)
signal health_changed(player_number: int, health: float, max_health: float)

var player1: Player
var player2: Player
var game_over := false
var hud: CanvasLayer

func _ready():
	# Get player references from scene
	player1 = get_node("Arena/Player1")
	player2 = get_node("Arena/Player2")
	
	if player1:
		player1.set_player_number(1)
		player1.health_changed.connect(_on_player_health_changed)
		player1.defeated.connect(on_player_defeated)
	if player2:
		player2.set_player_number(2)
		player2.health_changed.connect(_on_player_health_changed)
		player2.defeated.connect(on_player_defeated)
	hud = get_node("HUD")
	health_changed.connect(hud.update_health)
	player_won.connect(hud.show_winner)

	# Emit initial HUD values once numbers are assigned and HUD is connected.
	if player1:
		health_changed.emit(player1.player_number, player1.health, player1.max_health)
	if player2:
		health_changed.emit(player2.player_number, player2.health, player2.max_health)

func _process(_delta):
	if game_over:
		return

func _on_player_health_changed(player_number: int, health: float, max_health: float):
	health_changed.emit(player_number, health, max_health)

func on_player_defeated(player_number: int):
	if game_over:
		return

	game_over = true
	var winner = 3 - player_number  # If player 1 lost, player 2 won
	player_won.emit(winner)
	print("Player %d wins!" % winner)

func reset_game():
	print("Resetting game...")
	if is_instance_valid(player1):
		player1.health = player1.max_health
		player1.position = Vector2(200, 300)
		health_changed.emit(player1.player_number, player1.health, player1.max_health)
	if is_instance_valid(player2):
		player2.health = player2.max_health
		player2.position = Vector2(800, 300)
		health_changed.emit(player2.player_number, player2.health, player2.max_health)
	game_over = false
