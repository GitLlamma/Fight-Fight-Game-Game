extends Node

const DEFAULT_CHARACTER_ID: StringName = &"default_fighter"
const INPUT_MODE_KEYBOARD: StringName = &"keyboard"
const INPUT_MODE_CONTROLLER: StringName = &"controller"
const CONTROLLER_BINDING_JUMP: StringName = &"jump"
const CONTROLLER_BINDING_ATTACK: StringName = &"attack"
const CONTROLLER_DEVICE_AUTO_ID := -1

var default_player_character_ids := {
	1: DEFAULT_CHARACTER_ID,
	2: DEFAULT_CHARACTER_ID,
}
var default_player_input_modes := {
	1: INPUT_MODE_CONTROLLER,
	2: INPUT_MODE_CONTROLLER,
}
var default_player_controller_device_ids := {
	1: CONTROLLER_DEVICE_AUTO_ID,
	2: CONTROLLER_DEVICE_AUTO_ID,
}
var selected_character_ids := {}
var selected_skin_ids := {}
var selected_loadout_ids := {}
var selected_input_modes := {}
var selected_controller_device_ids := {}
var default_controller_bindings := {
	1: {
		CONTROLLER_BINDING_JUMP: JOY_BUTTON_A,
		CONTROLLER_BINDING_ATTACK: JOY_BUTTON_X,
	},
	2: {
		CONTROLLER_BINDING_JUMP: JOY_BUTTON_A,
		CONTROLLER_BINDING_ATTACK: JOY_BUTTON_X,
	},
}
var selected_controller_bindings := {}

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
	if not selected_input_modes.has(1):
		selected_input_modes[1] = default_player_input_modes[1]
	if not selected_input_modes.has(2):
		selected_input_modes[2] = default_player_input_modes[2]
	if not selected_controller_device_ids.has(1):
		selected_controller_device_ids[1] = default_player_controller_device_ids[1]
	if not selected_controller_device_ids.has(2):
		selected_controller_device_ids[2] = default_player_controller_device_ids[2]
	if not selected_controller_bindings.has(1):
		selected_controller_bindings[1] = default_controller_bindings[1].duplicate(true)
	if not selected_controller_bindings.has(2):
		selected_controller_bindings[2] = default_controller_bindings[2].duplicate(true)

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
	selected_input_modes = default_player_input_modes.duplicate()
	selected_controller_device_ids = default_player_controller_device_ids.duplicate()
	selected_controller_bindings = {
		1: default_controller_bindings[1].duplicate(true),
		2: default_controller_bindings[2].duplicate(true),
	}

func set_player_selection(player_number: int, character_id: StringName, skin_id: StringName = &"", loadout_id: StringName = &"") -> void:
	selected_character_ids[player_number] = _sanitize_character_id(character_id)
	selected_skin_ids[player_number] = skin_id
	selected_loadout_ids[player_number] = loadout_id

func set_player_input_mode(player_number: int, input_mode: StringName) -> void:
	selected_input_modes[player_number] = _sanitize_input_mode(input_mode)

func get_player_input_mode(player_number: int, fallback_mode: StringName = INPUT_MODE_CONTROLLER) -> StringName:
	if selected_input_modes.has(player_number):
		return selected_input_modes[player_number]
	if default_player_input_modes.has(player_number):
		return default_player_input_modes[player_number]
	return _sanitize_input_mode(fallback_mode)

func set_player_controller_device_id(player_number: int, device_id: int) -> void:
	selected_controller_device_ids[player_number] = _sanitize_controller_device_id(device_id)

func get_player_controller_device_id(player_number: int, fallback_device_id: int = CONTROLLER_DEVICE_AUTO_ID) -> int:
	if selected_controller_device_ids.has(player_number):
		return int(selected_controller_device_ids[player_number])
	if default_player_controller_device_ids.has(player_number):
		return int(default_player_controller_device_ids[player_number])
	return _sanitize_controller_device_id(fallback_device_id)

func set_player_controller_binding(player_number: int, binding_name: StringName, button_index: int) -> void:
	_ensure_player_controller_bindings(player_number)
	var sanitized_binding: StringName = _sanitize_controller_binding_name(binding_name)
	selected_controller_bindings[player_number][sanitized_binding] = button_index

func get_player_controller_binding(player_number: int, binding_name: StringName, fallback_button: int = JOY_BUTTON_INVALID) -> int:
	_ensure_player_controller_bindings(player_number)
	var sanitized_binding: StringName = _sanitize_controller_binding_name(binding_name)
	var fallback_resolved: int = fallback_button
	if fallback_resolved == JOY_BUTTON_INVALID:
		fallback_resolved = _get_default_controller_binding(player_number, sanitized_binding)
	return int(selected_controller_bindings[player_number].get(sanitized_binding, fallback_resolved))

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
		"input_mode": get_player_input_mode(player_number),
		"controller_device_id": get_player_controller_device_id(player_number),
		"controller_bindings": selected_controller_bindings.get(player_number, {}),
	}

func _sanitize_character_id(character_id: StringName) -> StringName:
	return character_id if character_id != &"" else DEFAULT_CHARACTER_ID

func _sanitize_input_mode(input_mode: StringName) -> StringName:
	if input_mode == INPUT_MODE_CONTROLLER:
		return INPUT_MODE_CONTROLLER
	return INPUT_MODE_KEYBOARD

func _sanitize_controller_binding_name(binding_name: StringName) -> StringName:
	if binding_name == CONTROLLER_BINDING_ATTACK:
		return CONTROLLER_BINDING_ATTACK
	return CONTROLLER_BINDING_JUMP

func _sanitize_controller_device_id(device_id: int) -> int:
	if device_id < 0:
		return CONTROLLER_DEVICE_AUTO_ID
	return device_id

func _ensure_player_controller_bindings(player_number: int) -> void:
	if selected_controller_bindings.has(player_number):
		return
	selected_controller_bindings[player_number] = {
		CONTROLLER_BINDING_JUMP: _get_default_controller_binding(player_number, CONTROLLER_BINDING_JUMP),
		CONTROLLER_BINDING_ATTACK: _get_default_controller_binding(player_number, CONTROLLER_BINDING_ATTACK),
	}

func _get_default_controller_binding(player_number: int, binding_name: StringName) -> int:
	var default_for_player: Dictionary = default_controller_bindings.get(player_number, default_controller_bindings[1])
	return int(default_for_player.get(binding_name, JOY_BUTTON_A))