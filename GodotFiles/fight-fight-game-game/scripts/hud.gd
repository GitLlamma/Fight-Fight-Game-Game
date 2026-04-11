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
@onready var character_select_start_warning_label = $CharacterSelectScreen/SelectContent/StartWarningLabel
@onready var start_match_button = $CharacterSelectBackground/StartMatchButton
@onready var back_to_main_menu_button = $CharacterSelectBackground/BackToMainMenuButton
@onready var controller_reconnect_overlay = $ControllerReconnectOverlay
@onready var controller_reconnect_body_label = $ControllerReconnectOverlay/ReconnectContent/ReconnectBodyLabel
@onready var controls_background = $ControlsBackground
@onready var controls_screen = $ControlsScreen
@onready var controls_player_tabs = $ControlsScreen/ControlsContent/PlayerTabs
@onready var controls_back_button = $ControlsBackground/BackButton
@onready var p1_keyboard_input_button = $ControlsScreen/ControlsContent/PlayerTabs/Player1Tab/P1InputModeRow/P1InputModeSwitch/KeyboardButton
@onready var p1_controller_input_button = $ControlsScreen/ControlsContent/PlayerTabs/Player1Tab/P1InputModeRow/P1InputModeSwitch/ControllerButton
@onready var p1_controller_status_label = $ControlsScreen/ControlsContent/PlayerTabs/Player1Tab/P1ControllerStatusLabel
@onready var p1_controller_device_option = $ControlsScreen/ControlsContent/PlayerTabs/Player1Tab/P1ControllerDeviceRow/P1ControllerDeviceOption
@onready var p2_keyboard_input_button = $ControlsScreen/ControlsContent/PlayerTabs/Player2Tab/P2InputModeRow/P2InputModeSwitch/KeyboardButton
@onready var p2_controller_input_button = $ControlsScreen/ControlsContent/PlayerTabs/Player2Tab/P2InputModeRow/P2InputModeSwitch/ControllerButton
@onready var p2_controller_status_label = $ControlsScreen/ControlsContent/PlayerTabs/Player2Tab/P2ControllerStatusLabel
@onready var p2_controller_device_option = $ControlsScreen/ControlsContent/PlayerTabs/Player2Tab/P2ControllerDeviceRow/P2ControllerDeviceOption
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
@onready var controller_assignment_warning_label = $ControlsScreen/ControlsContent/ControllerAssignmentWarningLabel

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
var pending_rebind_mode: StringName = &""
var pending_rebind_player_number := 0
var left_axis_nav_held := false
var right_axis_nav_held := false
var up_axis_nav_held := false
var down_axis_nav_held := false
var main_menu_focus_target: StringName = &"start"

const CONTROLS_TAB_TITLE_P1_KEY := "UI_TAB_PLAYER_1"
const CONTROLS_TAB_TITLE_P2_KEY := "UI_TAB_PLAYER_2"
const REBIND_PROMPT_TEXT := "Press any key..."
const REBIND_CONTROLLER_PROMPT_TEXT := "Press any controller button..."
const MATCH_SETUP_NODE_PATH := "/root/MatchSetup"
const INPUT_MODE_KEYBOARD: StringName = &"keyboard"
const INPUT_MODE_CONTROLLER: StringName = &"controller"
const REBIND_MODE_KEYBOARD: StringName = &"keyboard"
const REBIND_MODE_CONTROLLER: StringName = &"controller"
const CONTROLLER_BINDING_JUMP: StringName = &"jump"
const CONTROLLER_BINDING_ATTACK: StringName = &"attack"
const CONTROLLER_DEVICE_AUTO_ID := -1
const CONTROLLER_DEVICE_AUTO_LABEL := "Auto (By Player Index)"
const COLOR_STATUS_OK := Color(0.75, 0.95, 0.8, 1.0)
const COLOR_STATUS_WARN := Color(0.98, 0.72, 0.72, 1.0)
const COLOR_STATUS_NEUTRAL := Color(0.85, 0.85, 0.85, 1.0)
const MENU_HIGHLIGHT_COLOR := Color(1.0, 1.0, 1.0, 1.0)
const MENU_DIM_COLOR := Color(0.8, 0.8, 0.8, 1.0)
const CONTROLLER_MENU_NAV_DEADZONE := 0.55
const MAIN_MENU_TARGET_START: StringName = &"start"
const MAIN_MENU_TARGET_CONTROLS: StringName = &"controls"
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
	controller_reconnect_overlay.hide()
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
	p1_controller_device_option.item_selected.connect(_on_p1_controller_device_option_selected)
	p2_controller_device_option.item_selected.connect(_on_p2_controller_device_option_selected)
	p1_character_option.item_selected.connect(_on_character_option_changed)
	p2_character_option.item_selected.connect(_on_character_option_changed)
	main_menu_start_button.focus_entered.connect(_on_main_menu_start_focus_entered)
	main_menu_start_button.focus_exited.connect(_refresh_main_menu_button_selection_visuals)
	main_menu_controls_button.focus_entered.connect(_on_main_menu_controls_focus_entered)
	main_menu_controls_button.focus_exited.connect(_refresh_main_menu_button_selection_visuals)
	_initialize_control_binding_buttons()
	_load_input_modes_from_match_setup()
	_validate_required_rebind_actions()
	_refresh_control_binding_button_texts()
	_refresh_controls_tab_titles()
	_refresh_input_mode_switch_visuals()
	_refresh_controller_device_options()
	_refresh_controller_connection_status_labels()
	_refresh_controller_assignment_warning()
	_refresh_start_match_availability()
	_focus_default_for_visible_menu()
	_refresh_main_menu_button_selection_visuals()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh_controls_tab_titles()

func _input(event: InputEvent) -> void:
	if pending_rebind_action == &"":
		return

	if event is InputEventJoypadButton and pending_rebind_mode == REBIND_MODE_CONTROLLER:
		var joy_event := event as InputEventJoypadButton
		if not joy_event.pressed:
			get_viewport().set_input_as_handled()
			return

		if not _can_accept_controller_rebind_event(joy_event.device, pending_rebind_player_number):
			get_viewport().set_input_as_handled()
			return

		_apply_controller_binding(_get_controller_binding_name_from_action(pending_rebind_action), joy_event.button_index, pending_rebind_player_number)
		_clear_pending_rebind()
		_refresh_control_binding_button_texts()
		get_viewport().set_input_as_handled()
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

		if pending_rebind_mode == REBIND_MODE_CONTROLLER:
			# Ignore non-escape keys while waiting for controller button input.
			get_viewport().set_input_as_handled()
			return

		_apply_keyboard_binding(pending_rebind_action, key_event)
		_clear_pending_rebind()
		_refresh_control_binding_button_texts()
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if pending_rebind_action != &"":
		return
	if not _is_menu_navigation_active():
		return

	if event is InputEventJoypadButton:
		var button_event := event as InputEventJoypadButton
		if not button_event.pressed:
			return

		match button_event.button_index:
			JOY_BUTTON_DPAD_LEFT:
				_send_ui_action("ui_left")
				get_viewport().set_input_as_handled()
			JOY_BUTTON_DPAD_RIGHT:
				_send_ui_action("ui_right")
				get_viewport().set_input_as_handled()
			JOY_BUTTON_DPAD_UP:
				_send_ui_action("ui_up")
				get_viewport().set_input_as_handled()
			JOY_BUTTON_DPAD_DOWN:
				_send_ui_action("ui_down")
				get_viewport().set_input_as_handled()
			JOY_BUTTON_A:
				_send_ui_action("ui_accept")
				get_viewport().set_input_as_handled()
			JOY_BUTTON_B:
				_handle_controller_back_action()
				get_viewport().set_input_as_handled()

	if event is InputEventJoypadMotion:
		_handle_controller_axis_menu_navigation(event as InputEventJoypadMotion)

func update_health(player_number: int, health: float, max_health: float):
	var health_text := "%.0f / %.0f" % [health, max_health]
	if player_number == 1:
		p1_health_label.text = "P1 Health: %s" % health_text
	else:
		p2_health_label.text = "P2 Health: %s" % health_text

func show_winner(player_number: int):
	win_screen.show()
	win_label.text = "Player %d Wins!" % player_number
	_focus_default_for_visible_menu()

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
	_focus_default_for_visible_menu()
	_refresh_main_menu_button_selection_visuals()

func hide_main_menu() -> void:
	main_menu_background.hide()
	main_menu_screen.hide()

func show_controls_screen() -> void:
	controls_background.show()
	controls_screen.show()
	controls_player_tabs.current_tab = 0
	_clear_pending_rebind()
	_refresh_controller_device_options()
	_refresh_control_binding_button_texts()
	_refresh_controller_connection_status_labels()
	_refresh_controller_assignment_warning()
	main_menu_background.hide()
	main_menu_screen.hide()
	character_select_background.hide()
	character_select_screen.hide()
	hide_winner()
	_focus_default_for_visible_menu()

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
	controller_reconnect_overlay.hide()
	hide_winner()
	_populate_character_options(character_options, default_p1, default_p2)
	_refresh_start_match_availability()
	_focus_default_for_visible_menu()

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
	if not _is_controller_assignment_valid_for_match_start():
		_refresh_start_match_availability()
		return

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
	var target_player_number: int = _get_player_number_from_action(action_name)
	var should_use_controller_rebind: bool = _is_controller_binding_action(action_name) and _player_uses_controller(target_player_number)
	var player_uses_controller: bool = _player_uses_controller(target_player_number)

	if not InputMap.has_action(action_name):
		push_warning("Cannot rebind missing action: %s" % String(action_name))
		return

	if pending_rebind_action != &"" and pending_rebind_action != action_name:
		_clear_pending_rebind()

	if player_uses_controller and not _is_controller_binding_action(action_name):
		# Movement directions are fixed to stick/D-pad in controller mode.
		return

	pending_rebind_action = action_name
	pending_rebind_button = action_binding_buttons[action_name]
	pending_rebind_player_number = target_player_number
	pending_rebind_mode = REBIND_MODE_CONTROLLER if should_use_controller_rebind else REBIND_MODE_KEYBOARD
	pending_rebind_button.text = REBIND_CONTROLLER_PROMPT_TEXT if should_use_controller_rebind else REBIND_PROMPT_TEXT

func _clear_pending_rebind() -> void:
	if pending_rebind_action == &"":
		return

	pending_rebind_action = &""
	pending_rebind_button = null
	pending_rebind_mode = &""
	pending_rebind_player_number = 0
	_refresh_control_binding_button_texts()

func _refresh_control_binding_button_texts() -> void:
	for action_name in action_binding_buttons.keys():
		var button: Button = action_binding_buttons[action_name]
		if action_name == pending_rebind_action:
			button.text = REBIND_CONTROLLER_PROMPT_TEXT if pending_rebind_mode == REBIND_MODE_CONTROLLER else REBIND_PROMPT_TEXT
		else:
			if _should_show_controller_binding(action_name):
				button.text = _get_action_controller_binding_label(action_name)
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

func _apply_controller_binding(binding_name: StringName, button_index: int, player_number: int) -> void:
	if player_number != 1 and player_number != 2:
		return

	var match_setup: Node = get_node_or_null(MATCH_SETUP_NODE_PATH)
	if match_setup == null:
		return

	match_setup.set_player_controller_binding(player_number, binding_name, button_index)

func _get_action_controller_binding_label(action_name: StringName) -> String:
	if action_name == &"ui_left_p1" or action_name == &"ui_left_p2":
		return "Left Stick Left / D-Pad Left"
	if action_name == &"ui_right_p1" or action_name == &"ui_right_p2":
		return "Left Stick Right / D-Pad Right"
	if action_name == &"ui_up_p1" or action_name == &"ui_up_p2":
		return "Left Stick Up / D-Pad Up"
	if action_name == &"ui_down_p1" or action_name == &"ui_down_p2":
		return "Left Stick Down / D-Pad Down"

	var player_number: int = _get_player_number_from_action(action_name)
	var binding_name: StringName = _get_controller_binding_name_from_action(action_name)
	if binding_name == &"":
		return _get_action_keyboard_binding_label(action_name)

	var match_setup: Node = get_node_or_null(MATCH_SETUP_NODE_PATH)
	if match_setup == null:
		return _get_action_keyboard_binding_label(action_name)

	var button_index: int = int(match_setup.get_player_controller_binding(player_number, binding_name))
	return _joy_button_to_label(button_index)

func _joy_button_to_label(button_index: int) -> String:
	if button_index == JOY_BUTTON_A:
		return "A"
	if button_index == JOY_BUTTON_B:
		return "B"
	if button_index == JOY_BUTTON_X:
		return "X"
	if button_index == JOY_BUTTON_Y:
		return "Y"
	if button_index == JOY_BUTTON_LEFT_SHOULDER:
		return "LB"
	if button_index == JOY_BUTTON_RIGHT_SHOULDER:
		return "RB"
	if button_index == JOY_BUTTON_BACK:
		return "Back"
	if button_index == JOY_BUTTON_START:
		return "Start"
	if button_index == JOY_BUTTON_DPAD_UP:
		return "D-Pad Up"
	if button_index == JOY_BUTTON_DPAD_DOWN:
		return "D-Pad Down"
	if button_index == JOY_BUTTON_DPAD_LEFT:
		return "D-Pad Left"
	if button_index == JOY_BUTTON_DPAD_RIGHT:
		return "D-Pad Right"
	return "Button %d" % button_index

func _get_player_number_from_action(action_name: StringName) -> int:
	var action_text: String = String(action_name)
	if action_text.ends_with("_p2"):
		return 2
	return 1

func _is_controller_binding_action(action_name: StringName) -> bool:
	return action_name == &"jump_p1" or action_name == &"attack_p1" or action_name == &"jump_p2" or action_name == &"attack_p2"

func _get_controller_binding_name_from_action(action_name: StringName) -> StringName:
	if action_name == &"jump_p1" or action_name == &"jump_p2":
		return CONTROLLER_BINDING_JUMP
	if action_name == &"attack_p1" or action_name == &"attack_p2":
		return CONTROLLER_BINDING_ATTACK
	return &""

func _player_uses_controller(player_number: int) -> bool:
	if player_number == 2:
		return p2_uses_controller
	return p1_uses_controller

func _should_show_controller_binding(action_name: StringName) -> bool:
	return _player_uses_controller(_get_player_number_from_action(action_name))

func _on_p1_keyboard_input_button_pressed() -> void:
	p1_uses_controller = false
	_save_input_modes_to_match_setup()
	_clear_pending_rebind()
	_refresh_input_mode_switch_visuals()
	_refresh_control_binding_button_texts()
	_refresh_controller_connection_status_labels()
	_refresh_controller_assignment_warning()

func _on_p1_controller_input_button_pressed() -> void:
	p1_uses_controller = true
	_save_input_modes_to_match_setup()
	_clear_pending_rebind()
	_refresh_input_mode_switch_visuals()
	_refresh_control_binding_button_texts()
	_refresh_controller_connection_status_labels()
	_refresh_controller_assignment_warning()

func _on_p2_keyboard_input_button_pressed() -> void:
	p2_uses_controller = false
	_save_input_modes_to_match_setup()
	_clear_pending_rebind()
	_refresh_input_mode_switch_visuals()
	_refresh_control_binding_button_texts()
	_refresh_controller_connection_status_labels()
	_refresh_controller_assignment_warning()

func _on_p2_controller_input_button_pressed() -> void:
	p2_uses_controller = true
	_save_input_modes_to_match_setup()
	_clear_pending_rebind()
	_refresh_input_mode_switch_visuals()
	_refresh_control_binding_button_texts()
	_refresh_controller_connection_status_labels()
	_refresh_controller_assignment_warning()

func _load_input_modes_from_match_setup() -> void:
	var match_setup: Node = get_node_or_null(MATCH_SETUP_NODE_PATH)
	if match_setup == null:
		return

	p1_uses_controller = match_setup.get_player_input_mode(1, INPUT_MODE_CONTROLLER) == INPUT_MODE_CONTROLLER
	p2_uses_controller = match_setup.get_player_input_mode(2, INPUT_MODE_CONTROLLER) == INPUT_MODE_CONTROLLER

func _save_input_modes_to_match_setup() -> void:
	var match_setup: Node = get_node_or_null(MATCH_SETUP_NODE_PATH)
	if match_setup == null:
		return

	match_setup.set_player_input_mode(1, INPUT_MODE_CONTROLLER if p1_uses_controller else INPUT_MODE_KEYBOARD)
	match_setup.set_player_input_mode(2, INPUT_MODE_CONTROLLER if p2_uses_controller else INPUT_MODE_KEYBOARD)

func _refresh_input_mode_switch_visuals() -> void:
	_set_switch_button_visual(p1_keyboard_input_button, not p1_uses_controller)
	_set_switch_button_visual(p1_controller_input_button, p1_uses_controller)
	_set_switch_button_visual(p2_keyboard_input_button, not p2_uses_controller)
	_set_switch_button_visual(p2_controller_input_button, p2_uses_controller)
	p1_controller_device_option.disabled = not p1_uses_controller
	p2_controller_device_option.disabled = not p2_uses_controller

func _refresh_controller_device_options() -> void:
	_refresh_single_controller_device_option(p1_controller_device_option, 1)
	_refresh_single_controller_device_option(p2_controller_device_option, 2)

func _refresh_single_controller_device_option(option_button: OptionButton, player_number: int) -> void:
	var selected_device_id: int = _get_saved_controller_device_id(player_number)
	var connected_devices: PackedInt32Array = Input.get_connected_joypads()

	option_button.set_block_signals(true)
	option_button.clear()
	option_button.add_item(CONTROLLER_DEVICE_AUTO_LABEL, CONTROLLER_DEVICE_AUTO_ID)
	for device_id in connected_devices:
		option_button.add_item(_build_controller_device_option_label(device_id), device_id)
	_select_option_button_id(option_button, selected_device_id)
	option_button.set_block_signals(false)

func _build_controller_device_option_label(device_id: int) -> String:
	var joy_name: String = Input.get_joy_name(device_id)
	if joy_name.strip_edges().is_empty():
		joy_name = "Unknown Controller"
	return "%s (ID %d)" % [joy_name, device_id]

func _select_option_button_id(option_button: OptionButton, target_id: int) -> void:
	for item_index in option_button.item_count:
		if option_button.get_item_id(item_index) == target_id:
			option_button.select(item_index)
			return
	option_button.select(0)

func _on_p1_controller_device_option_selected(index: int) -> void:
	_set_saved_controller_device_id(1, p1_controller_device_option.get_item_id(index))
	_refresh_controller_connection_status_labels()
	_refresh_controller_assignment_warning()

func _on_p2_controller_device_option_selected(index: int) -> void:
	_set_saved_controller_device_id(2, p2_controller_device_option.get_item_id(index))
	_refresh_controller_connection_status_labels()
	_refresh_controller_assignment_warning()

func _set_saved_controller_device_id(player_number: int, device_id: int) -> void:
	var match_setup: Node = get_node_or_null(MATCH_SETUP_NODE_PATH)
	if match_setup == null:
		return
	match_setup.set_player_controller_device_id(player_number, device_id)

func _get_saved_controller_device_id(player_number: int) -> int:
	var match_setup: Node = get_node_or_null(MATCH_SETUP_NODE_PATH)
	if match_setup == null:
		return CONTROLLER_DEVICE_AUTO_ID
	return int(match_setup.get_player_controller_device_id(player_number, CONTROLLER_DEVICE_AUTO_ID))

func _can_accept_controller_rebind_event(event_device_id: int, player_number: int) -> bool:
	var selected_device_id: int = _get_saved_controller_device_id(player_number)
	if selected_device_id == CONTROLLER_DEVICE_AUTO_ID:
		return true
	return event_device_id == selected_device_id

func _refresh_controller_connection_status_labels() -> void:
	var connected_devices: PackedInt32Array = Input.get_connected_joypads()
	p1_controller_status_label.text = _build_controller_status_text(1, p1_uses_controller, connected_devices)
	p2_controller_status_label.text = _build_controller_status_text(2, p2_uses_controller, connected_devices)
	p1_controller_status_label.self_modulate = _build_controller_status_color(1, p1_uses_controller, connected_devices)
	p2_controller_status_label.self_modulate = _build_controller_status_color(2, p2_uses_controller, connected_devices)

func _build_controller_status_text(player_number: int, uses_controller: bool, connected_devices: PackedInt32Array) -> String:
	var connected_count := connected_devices.size()
	if connected_count <= 0:
		if uses_controller:
			return "P%d: Controller mode selected, but no controller is connected." % player_number
		return "P%d: No controllers connected." % player_number

	var selected_device_id: int = _get_saved_controller_device_id(player_number)
	var resolved_device_id: int = _resolve_controller_device_for_player(player_number, connected_devices)

	if uses_controller:
		if resolved_device_id < 0:
			return "P%d: Controller mode selected, but no usable controller is available." % player_number
		if selected_device_id == CONTROLLER_DEVICE_AUTO_ID:
			return "P%d: Auto device -> %s" % [player_number, _build_controller_device_option_label(resolved_device_id)]
		if selected_device_id != resolved_device_id:
			return "P%d: Selected device missing, fallback -> %s" % [player_number, _build_controller_device_option_label(resolved_device_id)]
		return "P%d: Selected device -> %s" % [player_number, _build_controller_device_option_label(resolved_device_id)]
	return "P%d: %d controller(s) connected (keyboard mode selected)." % [player_number, connected_count]

func _build_controller_status_color(player_number: int, uses_controller: bool, connected_devices: PackedInt32Array) -> Color:
	if uses_controller and _resolve_controller_device_for_player(player_number, connected_devices) < 0:
		return COLOR_STATUS_WARN
	if uses_controller:
		return COLOR_STATUS_OK
	return COLOR_STATUS_NEUTRAL

func _resolve_controller_device_for_player(player_number: int, connected_devices: PackedInt32Array) -> int:
	if connected_devices.is_empty():
		return -1

	var selected_device_id: int = _get_saved_controller_device_id(player_number)
	if selected_device_id != CONTROLLER_DEVICE_AUTO_ID and connected_devices.has(selected_device_id):
		return selected_device_id

	var fallback_index: int = player_number - 1
	if fallback_index >= 0 and fallback_index < connected_devices.size():
		return connected_devices[fallback_index]

	return connected_devices[0]

func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	_refresh_controller_device_options()
	_refresh_controller_connection_status_labels()
	_refresh_controller_assignment_warning()
	_refresh_start_match_availability()
	if main_menu_screen.visible:
		_focus_default_for_visible_menu()
	_refresh_main_menu_button_selection_visuals()

func _refresh_start_match_availability() -> void:
	if character_select_start_warning_label == null:
		return

	var controller_assignment_error: String = _get_match_start_controller_assignment_error()
	var can_start: bool = controller_assignment_error.is_empty()
	start_match_button.disabled = not can_start
	if can_start:
		character_select_start_warning_label.hide()
		return

	character_select_start_warning_label.text = controller_assignment_error
	character_select_start_warning_label.self_modulate = COLOR_STATUS_WARN
	character_select_start_warning_label.show()

func _get_match_start_controller_assignment_error() -> String:
	var connected_devices: PackedInt32Array = Input.get_connected_joypads()
	var p1_device: int = -1
	var p2_device: int = -1

	if p1_uses_controller:
		p1_device = _resolve_controller_device_for_player(1, connected_devices)
		if p1_device < 0:
			return "Cannot start: Player 1 is set to controller mode but no connected controller is assigned."

	if p2_uses_controller:
		p2_device = _resolve_controller_device_for_player(2, connected_devices)
		if p2_device < 0:
			return "Cannot start: Player 2 is set to controller mode but no connected controller is assigned."

	if p1_uses_controller and p2_uses_controller and p1_device == p2_device:
		return "Cannot start: both players in controller mode must be assigned different connected controllers."

	return ""

func _is_controller_assignment_valid_for_match_start() -> bool:
	return _get_match_start_controller_assignment_error().is_empty()

func show_controller_reconnect_prompt(waiting_players: Array[int]) -> void:
	if controller_reconnect_overlay == null:
		return
	if waiting_players.is_empty():
		hide_controller_reconnect_prompt()
		return

	var player_tokens: Array[String] = []
	for player_number in waiting_players:
		player_tokens.append("P%d" % player_number)
	controller_reconnect_body_label.text = "Waiting for controller input recovery: %s" % ", ".join(player_tokens)
	controller_reconnect_overlay.show()

func hide_controller_reconnect_prompt() -> void:
	if controller_reconnect_overlay:
		controller_reconnect_overlay.hide()

func _refresh_controller_assignment_warning() -> void:
	if controller_assignment_warning_label == null:
		return

	if not p1_uses_controller or not p2_uses_controller:
		controller_assignment_warning_label.hide()
		return

	var connected_devices: PackedInt32Array = Input.get_connected_joypads()
	if connected_devices.size() < 2:
		controller_assignment_warning_label.text = "Both players are in controller mode, but fewer than two controllers are connected."
		controller_assignment_warning_label.self_modulate = COLOR_STATUS_WARN
		controller_assignment_warning_label.show()
		return

	var p1_device: int = _resolve_controller_device_for_player(1, connected_devices)
	var p2_device: int = _resolve_controller_device_for_player(2, connected_devices)
	if p1_device >= 0 and p1_device == p2_device:
		controller_assignment_warning_label.text = "Both players are currently mapped to the same controller. Pick different devices for fair input separation."
		controller_assignment_warning_label.self_modulate = COLOR_STATUS_WARN
		controller_assignment_warning_label.show()
		return

	controller_assignment_warning_label.hide()

func _is_menu_navigation_active() -> bool:
	return main_menu_screen.visible or controls_screen.visible or character_select_screen.visible or win_screen.visible or controller_reconnect_overlay.visible

func _send_ui_action(action_name: String) -> void:
	var pressed_event := InputEventAction.new()
	pressed_event.action = action_name
	pressed_event.pressed = true
	Input.parse_input_event(pressed_event)

	var released_event := InputEventAction.new()
	released_event.action = action_name
	released_event.pressed = false
	Input.parse_input_event(released_event)

func _handle_controller_axis_menu_navigation(motion_event: InputEventJoypadMotion) -> void:
	if motion_event.axis == JOY_AXIS_LEFT_X:
		if motion_event.axis_value <= -CONTROLLER_MENU_NAV_DEADZONE:
			if not left_axis_nav_held:
				left_axis_nav_held = true
				_send_ui_action("ui_left")
				get_viewport().set_input_as_handled()
		else:
			left_axis_nav_held = false

		if motion_event.axis_value >= CONTROLLER_MENU_NAV_DEADZONE:
			if not right_axis_nav_held:
				right_axis_nav_held = true
				_send_ui_action("ui_right")
				get_viewport().set_input_as_handled()
		else:
			right_axis_nav_held = false

	if motion_event.axis == JOY_AXIS_LEFT_Y:
		if motion_event.axis_value <= -CONTROLLER_MENU_NAV_DEADZONE:
			if not up_axis_nav_held:
				up_axis_nav_held = true
				_send_ui_action("ui_up")
				get_viewport().set_input_as_handled()
		else:
			up_axis_nav_held = false

		if motion_event.axis_value >= CONTROLLER_MENU_NAV_DEADZONE:
			if not down_axis_nav_held:
				down_axis_nav_held = true
				_send_ui_action("ui_down")
				get_viewport().set_input_as_handled()
		else:
			down_axis_nav_held = false

func _handle_controller_back_action() -> void:
	if controls_screen.visible:
		_on_controls_back_button_pressed()
		return
	if character_select_screen.visible:
		_on_back_to_main_menu_button_pressed()
		return
	if win_screen.visible:
		_on_back_to_select_button_pressed()

func _focus_default_for_visible_menu() -> void:
	if main_menu_screen.visible:
		if _is_any_controller_connected():
			if main_menu_focus_target == MAIN_MENU_TARGET_CONTROLS:
				if not main_menu_controls_button.has_focus():
					main_menu_controls_button.grab_focus()
			elif not main_menu_start_button.has_focus():
				main_menu_start_button.grab_focus()
		_refresh_main_menu_button_selection_visuals()
		return
	if controls_screen.visible:
		if get_viewport().gui_get_focus_owner() == null:
			controls_back_button.grab_focus()
		return
	if character_select_screen.visible:
		if get_viewport().gui_get_focus_owner() == null:
			p1_character_option.grab_focus()
		return
	if win_screen.visible:
		if get_viewport().gui_get_focus_owner() == null:
			rematch_button.grab_focus()

func _is_any_controller_connected() -> bool:
	return not Input.get_connected_joypads().is_empty()

func _refresh_main_menu_button_selection_visuals() -> void:
	var controller_connected: bool = _is_any_controller_connected()
	if not main_menu_screen.visible:
		_set_menu_button_selected(main_menu_start_button, false)
		_set_menu_button_selected(main_menu_controls_button, false)
		return

	if not controller_connected:
		_set_menu_button_selected(main_menu_start_button, false)
		_set_menu_button_selected(main_menu_controls_button, false)
		return

	_set_menu_button_selected(main_menu_start_button, main_menu_start_button.has_focus())
	_set_menu_button_selected(main_menu_controls_button, main_menu_controls_button.has_focus())

func _set_menu_button_selected(button: Button, selected: bool) -> void:
	button.self_modulate = MENU_HIGHLIGHT_COLOR if selected else MENU_DIM_COLOR

func _on_main_menu_start_focus_entered() -> void:
	main_menu_focus_target = MAIN_MENU_TARGET_START
	_refresh_main_menu_button_selection_visuals()

func _on_main_menu_controls_focus_entered() -> void:
	main_menu_focus_target = MAIN_MENU_TARGET_CONTROLS
	_refresh_main_menu_button_selection_visuals()

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
