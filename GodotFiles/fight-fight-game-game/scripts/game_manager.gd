extends Node

class_name GameManager

const DEFAULT_CHARACTER_ID: StringName = &"default_fighter"
const CHARACTER_PROFILE_PATH_TEMPLATE := "res://characters/%s.tres"
const MATCH_SETUP_NODE_PATH := "/root/MatchSetup"

signal player_won(player_number: int)
signal health_changed(player_number: int, health: float, max_health: float)

@export var player_scene: PackedScene
@export var player1_character_id: StringName = DEFAULT_CHARACTER_ID
@export var player2_character_id: StringName = DEFAULT_CHARACTER_ID

var player1: Player
var player2: Player
var game_over := false
var hud: CanvasLayer

func _ready():
	hud = get_node("HUD")
	health_changed.connect(hud.update_health)
	player_won.connect(hud.show_winner)
	hud.match_start_requested.connect(_on_match_start_requested)
	hud.rematch_requested.connect(_on_rematch_requested)
	hud.character_select_requested.connect(_on_character_select_requested)
	_sync_selected_characters()
	hud.show_main_menu(_get_available_character_options(), player1_character_id, player2_character_id)

func _spawn_match_players():
	_sync_selected_characters()
	game_over = false
	hud.hide_winner()
	hud.hide_main_menu()
	hud.hide_controls_screen()
	hud.hide_character_select()
	_despawn_player(player1)
	_despawn_player(player2)
	player1 = null
	player2 = null

	var player1_spawn: Node2D = get_node("Arena/PlayerSpawns/Player1Spawn")
	var player2_spawn: Node2D = get_node("Arena/PlayerSpawns/Player2Spawn")
	player1 = _spawn_player(1, "Player1", player1_spawn, player1_character_id)
	player2 = _spawn_player(2, "Player2", player2_spawn, player2_character_id)

	# Emit initial HUD values once numbers are assigned and HUD is connected.
	if player1:
		health_changed.emit(player1.player_number, player1.health, player1.max_health)
	if player2:
		health_changed.emit(player2.player_number, player2.health, player2.max_health)

func _sync_selected_characters():
	var match_setup: Node = get_node_or_null(MATCH_SETUP_NODE_PATH)
	if match_setup == null:
		return

	match_setup.ensure_defaults(player1_character_id, player2_character_id)
	player1_character_id = match_setup.get_selected_character_id(1, player1_character_id)
	player2_character_id = match_setup.get_selected_character_id(2, player2_character_id)

func _get_available_character_options() -> Array:
	var character_options: Array = []
	var characters_dir := DirAccess.open("res://characters")
	if characters_dir == null:
		return [{"character_id": DEFAULT_CHARACTER_ID, "display_name": "Default Fighter"}]

	characters_dir.list_dir_begin()
	var entry_name: String = characters_dir.get_next()
	while entry_name != "":
		if not characters_dir.current_is_dir() and entry_name.ends_with(".tres"):
			var resource_path := "res://characters/%s" % entry_name
			var profile := load(resource_path) as CharacterData
			if profile:
				character_options.append({
					"character_id": profile.character_id,
					"display_name": profile.display_name,
					"max_health": profile.max_health,
					"speed": profile.speed,
					"attack_damage": profile.attack_damage * profile.strength_multiplier,
					"weight": profile.weight,
				})
		entry_name = characters_dir.get_next()
	characters_dir.list_dir_end()

	if character_options.is_empty():
		character_options.append({"character_id": DEFAULT_CHARACTER_ID, "display_name": "Default Fighter"})

	character_options.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return String(a.get("display_name", "")) < String(b.get("display_name", ""))
	)
	return character_options

func set_player_character_selection(player_number: int, character_id: StringName, skin_id: StringName = &"", loadout_id: StringName = &"") -> void:
	var sanitized_character_id: StringName = character_id if character_id != &"" else DEFAULT_CHARACTER_ID
	if player_number == 1:
		player1_character_id = sanitized_character_id
	elif player_number == 2:
		player2_character_id = sanitized_character_id

	var match_setup: Node = get_node_or_null(MATCH_SETUP_NODE_PATH)
	if match_setup:
		match_setup.set_player_selection(player_number, sanitized_character_id, skin_id, loadout_id)

func _on_match_start_requested(player1_selected_character_id: StringName, player2_selected_character_id: StringName) -> void:
	set_player_character_selection(1, player1_selected_character_id)
	set_player_character_selection(2, player2_selected_character_id)
	_spawn_match_players()

func _on_rematch_requested() -> void:
	reset_game()

func _on_character_select_requested() -> void:
	_sync_selected_characters()
	_despawn_player(player1)
	_despawn_player(player2)
	player1 = null
	player2 = null
	game_over = false
	hud.hide_winner()
	hud.show_character_select(_get_available_character_options(), player1_character_id, player2_character_id)

func _spawn_player(player_number: int, node_name: String, spawn_marker: Node2D, character_id: StringName) -> Player:
	if player_scene == null:
		push_error("GameManager.player_scene is not assigned")
		return null

	var player_instance: Player = player_scene.instantiate() as Player
	if player_instance == null:
		push_error("player_scene did not instantiate a Player")
		return null

	var character_profile: CharacterData = _load_character_profile(character_id)
	if character_profile:
		player_instance.character_profile = character_profile

	var arena: Node2D = get_node("Arena")
	player_instance.name = node_name
	arena.add_child(player_instance)
	player_instance.global_position = spawn_marker.global_position
	player_instance.set_player_number(player_number)
	player_instance.health_changed.connect(_on_player_health_changed)
	player_instance.defeated.connect(on_player_defeated)
	return player_instance

func _load_character_profile(character_id: StringName) -> CharacterData:
	var requested_id: StringName = character_id if character_id != &"" else DEFAULT_CHARACTER_ID
	var profile_path := CHARACTER_PROFILE_PATH_TEMPLATE % String(requested_id)
	if ResourceLoader.exists(profile_path):
		return load(profile_path) as CharacterData

	if requested_id != DEFAULT_CHARACTER_ID:
		push_warning("Character profile not found for %s, falling back to default" % requested_id)
		return _load_character_profile(DEFAULT_CHARACTER_ID)

	push_error("Default character profile is missing")
	return null

func _despawn_player(player):
	if player == null or not is_instance_valid(player):
		return
	if player.health_changed.is_connected(_on_player_health_changed):
		player.health_changed.disconnect(_on_player_health_changed)
	if player.defeated.is_connected(on_player_defeated):
		player.defeated.disconnect(on_player_defeated)
	player.queue_free()

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
	_spawn_match_players()
