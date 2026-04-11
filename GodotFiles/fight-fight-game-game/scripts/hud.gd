extends CanvasLayer

signal match_start_requested(player1_character_id: StringName, player2_character_id: StringName)
signal rematch_requested()
signal character_select_requested()

@onready var p1_health_label = $VBoxContainer/P1HealthLabel
@onready var p2_health_label = $VBoxContainer/P2HealthLabel
@onready var main_menu_background = $MainMenuBackground
@onready var main_menu_screen = $MainMenuScreen
@onready var main_menu_start_button = $MainMenuScreen/MainMenuContent/StartButton
@onready var main_menu_controls_button = $MainMenuScreen/MainMenuContent/ControlsButton
@onready var win_screen = $WinScreen
@onready var win_label = $WinScreen/WinContent/WinLabel
@onready var rematch_button = $WinScreen/WinContent/RematchButton
@onready var back_to_select_button = $WinScreen/WinContent/BackToSelectButton
@onready var character_select_background = $CharacterSelectBackground
@onready var character_select_screen = $CharacterSelectScreen
@onready var p1_character_option = $CharacterSelectScreen/SelectContent/PlayerColumns/P1Column/P1CharacterOption
@onready var p2_character_option = $CharacterSelectScreen/SelectContent/PlayerColumns/P2Column/P2CharacterOption
@onready var p1_preview_label = $CharacterSelectScreen/SelectContent/PlayerColumns/P1Column/P1PreviewLabel
@onready var p2_preview_label = $CharacterSelectScreen/SelectContent/PlayerColumns/P2Column/P2PreviewLabel
@onready var start_match_button = $CharacterSelectScreen/SelectContent/SelectActions/StartMatchButton
@onready var back_to_main_menu_button = $CharacterSelectScreen/SelectContent/SelectActions/BackToMainMenuButton
@onready var controls_background = $ControlsBackground
@onready var controls_screen = $ControlsScreen
@onready var controls_player_tabs = $ControlsScreen/ControlsContent/PlayerTabs
@onready var controls_back_button = $ControlsScreen/ControlsContent/BackButton
@onready var p1_keyboard_input_button = $ControlsScreen/ControlsContent/PlayerTabs/Player1Tab/P1InputModeRow/P1InputModeSwitch/KeyboardButton
@onready var p1_controller_input_button = $ControlsScreen/ControlsContent/PlayerTabs/Player1Tab/P1InputModeRow/P1InputModeSwitch/ControllerButton
@onready var p2_keyboard_input_button = $ControlsScreen/ControlsContent/PlayerTabs/Player2Tab/P2InputModeRow/P2InputModeSwitch/KeyboardButton
@onready var p2_controller_input_button = $ControlsScreen/ControlsContent/PlayerTabs/Player2Tab/P2InputModeRow/P2InputModeSwitch/ControllerButton
@onready var p1_left_button = $ControlsScreen/ControlsContent/PlayerTabs/Player1Tab/P1LeftRow/P1LeftButton
@onready var p1_right_button = $ControlsScreen/ControlsContent/PlayerTabs/Player1Tab/P1RightRow/P1RightButton
@onready var p1_up_button = $ControlsScreen/ControlsContent/PlayerTabs/Player1Tab/P1UpRow/P1UpButton
@onready var p1_down_button = $ControlsScreen/ControlsContent/PlayerTabs/Player1Tab/P1DownRow/P1DownButton
@onready var p1_jump_button = $ControlsScreen/ControlsContent/PlayerTabs/Player1Tab/P1JumpRow/P1JumpButton
@onready var p1_attack_button = $ControlsScreen/ControlsContent/PlayerTabs/Player1Tab/P1AttackRow/P1AttackButton
@onready var p2_left_button = $ControlsScreen/ControlsContent/PlayerTabs/Player2Tab/P2LeftRow/P2LeftButton
@onready var p2_right_button = $ControlsScreen/ControlsContent/PlayerTabs/Player2Tab/P2RightRow/P2RightButton
@onready var p2_up_button = $ControlsScreen/ControlsContent/PlayerTabs/Player2Tab/P2UpRow/P2UpButton
@onready var p2_down_button = $ControlsScreen/ControlsContent/PlayerTabs/Player2Tab/P2DownRow/P2DownButton
@onready var p2_jump_button = $ControlsScreen/ControlsContent/PlayerTabs/Player2Tab/P2JumpRow/P2JumpButton
@onready var p2_attack_button = $ControlsScreen/ControlsContent/PlayerTabs/Player2Tab/P2AttackRow/P2AttackButton

var character_ids_by_index: Array[StringName] = []
var character_options_by_id := {}
var cached_character_options: Array = []
var cached_default_p1: StringName = &"default_fighter"
var cached_default_p2: StringName = &"default_fighter"
var p1_uses_controller := false
var p2_uses_controller := false
var action_binding_buttons := {}
var pending_rebind_action: StringName = &""
var pending_rebind_button: Button = null

const CONTROLS_TAB_TITLE_P1_KEY := "UI_TAB_PLAYER_1"
const CONTROLS_TAB_TITLE_P2_KEY := "UI_TAB_PLAYER_2"
const REBIND_PROMPT_TEXT := "Press any key..."
const REQUIRED_REBIND_ACTIONS: Array[StringName] = [
	&"ui_left_p1",
	&"ui_right_p1",
	&"ui_up_p1",
	&"ui_down_p1",
	&"jump_p1",
	&"attack_p1",
	&"ui_left_p2",
	&"ui_right_p2",
	&"ui_up_p2",
	&"ui_down_p2",
	&"jump_p2",
	&"attack_p2",
]

func _ready():
	main_menu_background.hide()
	main_menu_screen.hide()
	win_screen.hide()
	character_select_background.hide()
	character_select_screen.hide()
	controls_background.hide()
	controls_screen.hide()
	main_menu_start_button.pressed.connect(_on_main_menu_start_button_pressed)
	main_menu_controls_button.pressed.connect(_on_main_menu_controls_button_pressed)
	rematch_button.pressed.connect(_on_rematch_button_pressed)
	back_to_select_button.pressed.connect(_on_back_to_select_button_pressed)
	start_match_button.pressed.connect(_on_start_match_button_pressed)
	back_to_main_menu_button.pressed.connect(_on_back_to_main_menu_button_pressed)
	controls_back_button.pressed.connect(_on_controls_back_button_pressed)
	p1_keyboard_input_button.pressed.connect(_on_p1_keyboard_input_button_pressed)
	p1_controller_input_button.pressed.connect(_on_p1_controller_input_button_pressed)
	p2_keyboard_input_button.pressed.connect(_on_p2_keyboard_input_button_pressed)
	p2_controller_input_button.pressed.connect(_on_p2_controller_input_button_pressed)
	p1_character_option.item_selected.connect(_on_character_option_changed)
	p2_character_option.item_selected.connect(_on_character_option_changed)
	_initialize_control_binding_buttons()
	_validate_required_rebind_actions()
	_refresh_control_binding_button_texts()
	_refresh_controls_tab_titles()
	_refresh_input_mode_switch_visuals()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh_controls_tab_titles()

func _input(event: InputEvent) -> void:
	if pending_rebind_action == &"":
		return

	if event is InputEventKey:
		var key_event := event as InputEventKey
		# Consume all key events while waiting for a rebind so UI focus navigation
		# (especially arrow keys) does not steal the input from remapping.
		if not key_event.pressed or key_event.echo:
			get_viewport().set_input_as_handled()
			return

		if key_event.keycode == KEY_ESCAPE:
			_clear_pending_rebind()
			get_viewport().set_input_as_handled()
			return

		_apply_keyboard_binding(pending_rebind_action, key_event)
		_clear_pending_rebind()
		_refresh_control_binding_button_texts()
		get_viewport().set_input_as_handled()

func update_health(player_number: int, health: float, max_health: float):
	var health_text := "%.0f / %.0f" % [health, max_health]
	if player_number == 1:
		p1_health_label.text = "P1 Health: %s" % health_text
	else:
		p2_health_label.text = "P2 Health: %s" % health_text

func show_winner(player_number: int):
	win_screen.show()
	win_label.text = "Player %d Wins!" % player_number

func hide_winner() -> void:
	win_screen.hide()

func show_main_menu(character_options: Array, default_p1: StringName, default_p2: StringName) -> void:
	cache_character_select_data(character_options, default_p1, default_p2)
	main_menu_background.show()
	main_menu_screen.show()
	character_select_background.hide()
	controls_background.hide()
	controls_screen.hide()
	character_select_screen.hide()
	hide_winner()

func hide_main_menu() -> void:
	main_menu_background.hide()
	main_menu_screen.hide()

func show_controls_screen() -> void:
	controls_background.show()
	controls_screen.show()
	controls_player_tabs.current_tab = 0
	_clear_pending_rebind()
	_refresh_control_binding_button_texts()
	main_menu_background.hide()
	main_menu_screen.hide()
	character_select_background.hide()
	character_select_screen.hide()
	hide_winner()

func hide_controls_screen() -> void:
	_clear_pending_rebind()
	controls_background.hide()
	controls_screen.hide()

func cache_character_select_data(character_options: Array, default_p1: StringName, default_p2: StringName) -> void:
	cached_character_options = character_options.duplicate(true)
	cached_default_p1 = default_p1
	cached_default_p2 = default_p2

func show_character_select(character_options: Array, default_p1: StringName, default_p2: StringName) -> void:
	cache_character_select_data(character_options, default_p1, default_p2)
	main_menu_background.hide()
	main_menu_screen.hide()
	character_select_background.show()
	controls_background.hide()
	controls_screen.hide()
	character_select_screen.show()
	hide_winner()
	_populate_character_options(character_options, default_p1, default_p2)

func hide_character_select() -> void:
	character_select_background.hide()
	character_select_screen.hide()

func _populate_character_options(character_options: Array, default_p1: StringName, default_p2: StringName) -> void:
	character_ids_by_index.clear()
	character_options_by_id.clear()
	p1_character_option.clear()
	p2_character_option.clear()

	for option in character_options:
		var character_id: StringName = option.get("character_id", &"default_fighter")
		var display_name: String = option.get("display_name", String(character_id))
		character_ids_by_index.append(character_id)
		character_options_by_id[character_id] = option
		p1_character_option.add_item(display_name)
		p2_character_option.add_item(display_name)

	_select_character_option(p1_character_option, default_p1)
	_select_character_option(p2_character_option, default_p2)
	_refresh_character_previews()

func _select_character_option(option_button: OptionButton, target_character_id: StringName) -> void:
	for index in character_ids_by_index.size():
		if character_ids_by_index[index] == target_character_id:
			option_button.select(index)
			return

	if character_ids_by_index.size() > 0:
		option_button.select(0)

func _get_selected_character_id(option_button: OptionButton) -> StringName:
	if character_ids_by_index.is_empty():
		return &"default_fighter"

	var selected_index: int = option_button.selected
	if selected_index < 0 or selected_index >= character_ids_by_index.size():
		return character_ids_by_index[0]
	return character_ids_by_index[selected_index]

func _refresh_character_previews() -> void:
	p1_preview_label.text = _build_preview_text(_get_selected_character_id(p1_character_option))
	p2_preview_label.text = _build_preview_text(_get_selected_character_id(p2_character_option))

func _build_preview_text(character_id: StringName) -> String:
	var option: Dictionary = character_options_by_id.get(character_id, {})
	if option.is_empty():
		return "No fighter data available."

	return "%s\nHealth: %s\nSpeed: %s\nPower: %s\nWeight: %s" % [
		String(option.get("display_name", String(character_id))),
		String.num(float(option.get("max_health", 0.0)), 0),
		String.num(float(option.get("speed", 0.0)), 0),
		String.num(float(option.get("attack_damage", 0.0)), 1),
		String.num(float(option.get("weight", 0.0)), 2),
	]

func _on_character_option_changed(_index: int) -> void:
	_refresh_character_previews()

func _on_start_match_button_pressed() -> void:
	match_start_requested.emit(
		_get_selected_character_id(p1_character_option),
		_get_selected_character_id(p2_character_option)
	)

func _on_main_menu_start_button_pressed() -> void:
	show_character_select(cached_character_options, cached_default_p1, cached_default_p2)

func _on_main_menu_controls_button_pressed() -> void:
	show_controls_screen()

func _on_controls_back_button_pressed() -> void:
	show_main_menu(cached_character_options, cached_default_p1, cached_default_p2)

func _on_back_to_main_menu_button_pressed() -> void:
	show_main_menu(cached_character_options, cached_default_p1, cached_default_p2)

func _initialize_control_binding_buttons() -> void:
	action_binding_buttons = {
		&"ui_left_p1": p1_left_button,
		&"ui_right_p1": p1_right_button,
		&"ui_up_p1": p1_up_button,
		&"ui_down_p1": p1_down_button,
		&"jump_p1": p1_jump_button,
		&"attack_p1": p1_attack_button,
		&"ui_left_p2": p2_left_button,
		&"ui_right_p2": p2_right_button,
		&"ui_up_p2": p2_up_button,
		&"ui_down_p2": p2_down_button,
		&"jump_p2": p2_jump_button,
		&"attack_p2": p2_attack_button,
	}

	for action_name in action_binding_buttons.keys():
		var button: Button = action_binding_buttons[action_name]
		button.pressed.connect(_on_control_binding_button_pressed.bind(action_name))

func _validate_required_rebind_actions() -> void:
	for action_name in REQUIRED_REBIND_ACTIONS:
		if not InputMap.has_action(action_name):
			push_warning("Missing input action in project settings: %s" % String(action_name))

func _on_control_binding_button_pressed(action_name: StringName) -> void:
	if not InputMap.has_action(action_name):
		push_warning("Cannot rebind missing action: %s" % String(action_name))
		return

	if pending_rebind_action != &"" and pending_rebind_action != action_name:
		_clear_pending_rebind()

	pending_rebind_action = action_name
	pending_rebind_button = action_binding_buttons[action_name]
	pending_rebind_button.text = REBIND_PROMPT_TEXT

func _clear_pending_rebind() -> void:
	if pending_rebind_action == &"":
		return

	pending_rebind_action = &""
	pending_rebind_button = null
	_refresh_control_binding_button_texts()

func _refresh_control_binding_button_texts() -> void:
	for action_name in action_binding_buttons.keys():
		var button: Button = action_binding_buttons[action_name]
		if action_name == pending_rebind_action:
			button.text = REBIND_PROMPT_TEXT
		else:
			button.text = _get_action_keyboard_binding_label(action_name)

func _get_action_keyboard_binding_label(action_name: StringName) -> String:
	var key_event := _get_first_keyboard_event(action_name)
	if key_event == null:
		return "Unassigned"

	var display_key: Key = key_event.physical_keycode if key_event.physical_keycode != KEY_NONE else key_event.keycode
	return OS.get_keycode_string(display_key)

func _get_first_keyboard_event(action_name: StringName) -> InputEventKey:
	if not InputMap.has_action(action_name):
		return null

	for existing_event in InputMap.action_get_events(action_name):
		if existing_event is InputEventKey:
			return existing_event as InputEventKey
	return null

func _apply_keyboard_binding(action_name: StringName, source_event: InputEventKey) -> void:
	if not InputMap.has_action(action_name):
		push_warning("Cannot apply binding to missing action: %s" % String(action_name))
		return

	for existing_event in InputMap.action_get_events(action_name):
		if existing_event is InputEventKey:
			InputMap.action_erase_event(action_name, existing_event)

	var remapped_event := InputEventKey.new()
	remapped_event.keycode = source_event.keycode
	remapped_event.physical_keycode = source_event.physical_keycode
	InputMap.action_add_event(action_name, remapped_event)

func _on_p1_keyboard_input_button_pressed() -> void:
	p1_uses_controller = false
	_refresh_input_mode_switch_visuals()

func _on_p1_controller_input_button_pressed() -> void:
	p1_uses_controller = true
	_refresh_input_mode_switch_visuals()

func _on_p2_keyboard_input_button_pressed() -> void:
	p2_uses_controller = false
	_refresh_input_mode_switch_visuals()

func _on_p2_controller_input_button_pressed() -> void:
	p2_uses_controller = true
	_refresh_input_mode_switch_visuals()

func _refresh_input_mode_switch_visuals() -> void:
	_set_switch_button_visual(p1_keyboard_input_button, not p1_uses_controller)
	_set_switch_button_visual(p1_controller_input_button, p1_uses_controller)
	_set_switch_button_visual(p2_keyboard_input_button, not p2_uses_controller)
	_set_switch_button_visual(p2_controller_input_button, p2_uses_controller)

func _refresh_controls_tab_titles() -> void:
	if controls_player_tabs == null or not is_instance_valid(controls_player_tabs):
		return
	if controls_player_tabs.get_tab_count() < 2:
		return
	controls_player_tabs.set_tab_title(0, tr(CONTROLS_TAB_TITLE_P1_KEY))
	controls_player_tabs.set_tab_title(1, tr(CONTROLS_TAB_TITLE_P2_KEY))

func _set_switch_button_visual(button: Button, active: bool) -> void:
	button.button_pressed = active
	if active:
		button.self_modulate = Color(0.85, 1.0, 0.9, 1.0)
	else:
		button.self_modulate = Color(0.55, 0.55, 0.55, 1.0)

func _on_rematch_button_pressed() -> void:
	rematch_requested.emit()

func _on_back_to_select_button_pressed() -> void:
	character_select_requested.emit()
