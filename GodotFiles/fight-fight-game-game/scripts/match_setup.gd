extends Node

const DEFAULT_CHARACTER_ID: StringName = &"default_fighter"

var default_player_character_ids := {
	1: DEFAULT_CHARACTER_ID,
	2: DEFAULT_CHARACTER_ID,
}
var selected_character_ids := {}
var selected_skin_ids := {}
var selected_loadout_ids := {}

func _ready():
	reset_to_defaults()

func ensure_defaults(player1_character_id: StringName, player2_character_id: StringName) -> void:
	default_player_character_ids[1] = _sanitize_character_id(player1_character_id)
	default_player_character_ids[2] = _sanitize_character_id(player2_character_id)

	if not selected_character_ids.has(1):
		selected_character_ids[1] = default_player_character_ids[1]
	if not selected_character_ids.has(2):
		selected_character_ids[2] = default_player_character_ids[2]
	if not selected_skin_ids.has(1):
		selected_skin_ids[1] = &""
	if not selected_skin_ids.has(2):
		selected_skin_ids[2] = &""
	if not selected_loadout_ids.has(1):
		selected_loadout_ids[1] = &""
	if not selected_loadout_ids.has(2):
		selected_loadout_ids[2] = &""

func reset_to_defaults() -> void:
	selected_character_ids = default_player_character_ids.duplicate()
	selected_skin_ids = {
		1: &"",
		2: &"",
	}
	selected_loadout_ids = {
		1: &"",
		2: &"",
	}

func set_player_selection(player_number: int, character_id: StringName, skin_id: StringName = &"", loadout_id: StringName = &"") -> void:
	selected_character_ids[player_number] = _sanitize_character_id(character_id)
	selected_skin_ids[player_number] = skin_id
	selected_loadout_ids[player_number] = loadout_id

func get_selected_character_id(player_number: int, fallback_character_id: StringName = DEFAULT_CHARACTER_ID) -> StringName:
	if selected_character_ids.has(player_number):
		return selected_character_ids[player_number]
	if default_player_character_ids.has(player_number):
		return default_player_character_ids[player_number]
	return _sanitize_character_id(fallback_character_id)

func get_player_selection(player_number: int) -> Dictionary:
	return {
		"character_id": get_selected_character_id(player_number),
		"skin_id": selected_skin_ids.get(player_number, &""),
		"loadout_id": selected_loadout_ids.get(player_number, &""),
	}

func _sanitize_character_id(character_id: StringName) -> StringName:
	return character_id if character_id != &"" else DEFAULT_CHARACTER_ID