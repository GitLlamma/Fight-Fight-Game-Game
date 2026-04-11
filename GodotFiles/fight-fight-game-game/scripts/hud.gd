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
@onready var p1_lock_panel = $CharacterSelectScreen/SelectContent/LockStatusRow/P1LockPanel
@onready var p1_lock_label = $CharacterSelectScreen/SelectContent/LockStatusRow/P1LockPanel/P1LockLabel
@onready var p2_lock_panel = $CharacterSelectScreen/SelectContent/LockStatusRow/P2LockPanel
@onready var p2_lock_label = $CharacterSelectScreen/SelectContent/LockStatusRow/P2LockPanel/P2LockLabel
@onready var character_select_hint_label = $CharacterSelectScreen/SelectContent/HintLabel
@onready var mouse_owner_p1_button = $CharacterSelectScreen/SelectContent/MouseOwnerRow/MouseOwnerP1Button
@onready var mouse_owner_p2_button = $CharacterSelectScreen/SelectContent/MouseOwnerRow/MouseOwnerP2Button
@onready var character_grid = $CharacterSelectScreen/SelectContent/CharacterGrid
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
var character_grid_buttons: Array[Button] = []
var character_display_names_by_index: Array[String] = []
var mouse_owner_player_number := 1
var character_select_player_state := {}
var character_select_device_to_player := {}
var character_select_axis_hold_by_device := {}
var character_select_prev_locked_state := {
	1: false,
	2: false,
}
var character_select_lock_pulse_tweens := {}
var character_select_lock_panel_style_cache := {}
var character_select_lock_panel_applied_state := {
	1: null,
	2: null,
}

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
const COLOR_STATUS_OK := Color(0.75, 0.95, 0.8, 1.0)
const COLOR_STATUS_WARN := Color(0.98, 0.72, 0.72, 1.0)
const COLOR_STATUS_NEUTRAL := Color(0.85, 0.85, 0.85, 1.0)
const MENU_HIGHLIGHT_COLOR := Color(1.0, 1.0, 1.0, 1.0)
const MENU_DIM_COLOR := Color(0.8, 0.8, 0.8, 1.0)
const CONTROLLER_MENU_NAV_DEADZONE := 0.55
const PLAYER_SLOT_IDS: Array[int] = [1, 2]
const PLAYER_CURSOR_COLOR_P1 := Color(1.0, 0.7, 0.7, 1.0)
const PLAYER_CURSOR_COLOR_P2 := Color(0.7, 0.85, 1.0, 1.0)
const PLAYER_CURSOR_COLOR_BOTH := Color(0.85, 0.7, 1.0, 1.0)
const PLAYER_LOCK_COLOR_P1 := Color(0.95, 0.2, 0.2, 1.0)
const PLAYER_LOCK_COLOR_P2 := Color(0.22, 0.5, 1.0, 1.0)
const PLAYER_LOCK_COLOR_BOTH := Color(1.0, 0.55, 1.0, 1.0)
const CHARACTER_TILE_IDLE_COLOR := Color(0.72, 0.72, 0.72, 1.0)
const PLAYER_LOCK_PANEL_IDLE_COLOR := Color(0.3, 0.3, 0.3, 1.0)
const PLAYER_LOCK_PANEL_IDLE_BORDER_COLOR := Color(0.55, 0.55, 0.55, 1.0)
const PLAYER_LOCK_PANEL_TEXT_COLOR := Color(0.98, 0.98, 0.98, 1.0)
const CHARACTER_SELECT_HINT_DEFAULT := "CHOOSE YOUR CHARACTER"
const CHARACTER_SELECT_HINT_READY := "PRESS START/ENTER"
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
	mouse_owner_p1_button.pressed.connect(_on_mouse_owner_p1_button_pressed)
	mouse_owner_p2_button.pressed.connect(_on_mouse_owner_p2_button_pressed)
	controls_back_button.pressed.connect(_on_controls_back_button_pressed)
	p1_keyboard_input_button.pressed.connect(_on_p1_keyboard_input_button_pressed)
	p1_controller_input_button.pressed.connect(_on_p1_controller_input_button_pressed)
	p2_keyboard_input_button.pressed.connect(_on_p2_keyboard_input_button_pressed)
	p2_controller_input_button.pressed.connect(_on_p2_controller_input_button_pressed)
	p1_character_option.item_selected.connect(_on_character_option_changed)
	p2_character_option.item_selected.connect(_on_character_option_changed)
	main_menu_start_button.focus_entered.connect(_on_main_menu_start_focus_entered)
	main_menu_start_button.focus_exited.connect(_refresh_main_menu_button_selection_visuals)
	main_menu_controls_button.focus_entered.connect(_on_main_menu_controls_focus_entered)
	main_menu_controls_button.focus_exited.connect(_refresh_main_menu_button_selection_visuals)
	mouse_owner_p1_button.focus_mode = Control.FOCUS_NONE
	mouse_owner_p2_button.focus_mode = Control.FOCUS_NONE
	_initialize_lock_panel_style_cache()
	_initialize_control_binding_buttons()
	_load_input_modes_from_match_setup()
	_validate_required_rebind_actions()
	_refresh_control_binding_button_texts()
	_refresh_controls_tab_titles()
	_refresh_input_mode_switch_visuals()
	_refresh_controller_assignment_warning()
	_refresh_start_match_availability()
	_focus_default_for_visible_menu()
	_refresh_main_menu_button_selection_visuals()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh_controls_tab_titles()

func _input(event: InputEvent) -> void:
	if character_select_screen.visible:
		if event is InputEventJoypadButton:
			if _handle_character_select_controller_button(event as InputEventJoypadButton):
				get_viewport().set_input_as_handled()
				return
			# Never allow joypad buttons to fall through to generic UI focus navigation in Character Select.
			get_viewport().set_input_as_handled()
			return
		elif event is InputEventJoypadMotion:
			if _handle_character_select_controller_motion(event as InputEventJoypadMotion):
				get_viewport().set_input_as_handled()
				return
			# Consume non-actionable motion to keep focus from leaving the grid area.
			get_viewport().set_input_as_handled()
			return

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
	if character_select_screen.visible and event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and (key_event.keycode == KEY_ENTER or key_event.keycode == KEY_KP_ENTER):
			if _can_keyboard_shortcut_start_match():
				_on_start_match_button_pressed()
			get_viewport().set_input_as_handled()
			return
	if character_select_screen.visible and (event is InputEventJoypadButton or event is InputEventJoypadMotion):
		# Character Select controller input is handled exclusively in _input.
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
			JOY_BUTTON_LEFT_SHOULDER:
				if controls_screen.visible:
					_switch_controls_tab(-1)
					get_viewport().set_input_as_handled()
			JOY_BUTTON_RIGHT_SHOULDER:
				if controls_screen.visible:
					_switch_controls_tab(1)
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
	_refresh_control_binding_button_texts()
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
	_reset_character_select_player_state()
	_refresh_start_match_availability()
	_focus_default_for_visible_menu()

func hide_character_select() -> void:
	character_select_background.hide()
	character_select_screen.hide()

func _populate_character_options(character_options: Array, default_p1: StringName, default_p2: StringName) -> void:
	character_ids_by_index.clear()
	character_display_names_by_index.clear()
	character_options_by_id.clear()
	p1_character_option.clear()
	p2_character_option.clear()
	_character_grid_clear_buttons()

	for option in character_options:
		var character_id: StringName = option.get("character_id", &"default_fighter")
		var display_name: String = option.get("display_name", String(character_id))
		character_ids_by_index.append(character_id)
		character_display_names_by_index.append(display_name)
		character_options_by_id[character_id] = option
		p1_character_option.add_item(display_name)
		p2_character_option.add_item(display_name)
		_create_character_grid_button(character_id, display_name)

	_select_character_option(p1_character_option, default_p1)
	_select_character_option(p2_character_option, default_p2)
	_refresh_mouse_owner_buttons_visuals()
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
	_refresh_character_select_hint_label()
	_refresh_lock_status_panels()
	_refresh_character_grid_visuals()

func _on_mouse_owner_p1_button_pressed() -> void:
	mouse_owner_player_number = 1
	_refresh_mouse_owner_buttons_visuals()

func _on_mouse_owner_p2_button_pressed() -> void:
	mouse_owner_player_number = 2
	_refresh_mouse_owner_buttons_visuals()

func _refresh_mouse_owner_buttons_visuals() -> void:
	if mouse_owner_player_number == 2:
		mouse_owner_p2_button.button_pressed = true
		mouse_owner_p1_button.button_pressed = false
	else:
		mouse_owner_p1_button.button_pressed = true
		mouse_owner_p2_button.button_pressed = false

	_set_menu_button_selected(mouse_owner_p1_button, mouse_owner_player_number == 1)
	_set_menu_button_selected(mouse_owner_p2_button, mouse_owner_player_number == 2)

func _character_grid_clear_buttons() -> void:
	for child in character_grid.get_children():
		child.queue_free()
	character_grid_buttons.clear()

func _create_character_grid_button(character_id: StringName, display_name: String) -> void:
	var tile_button := Button.new()
	tile_button.text = display_name
	tile_button.custom_minimum_size = Vector2(120, 64)
	tile_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	tile_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tile_button.focus_mode = Control.FOCUS_NONE
	var base_style := _build_character_tile_stylebox(Color(1.0, 1.0, 1.0, 0.0))
	tile_button.add_theme_stylebox_override("normal", base_style)
	tile_button.add_theme_stylebox_override("hover", base_style.duplicate())
	tile_button.add_theme_stylebox_override("pressed", base_style.duplicate())
	tile_button.add_theme_stylebox_override("focus", base_style.duplicate())
	tile_button.pressed.connect(_on_character_grid_tile_pressed.bind(character_id))
	character_grid.add_child(tile_button)
	character_grid_buttons.append(tile_button)

func _build_character_tile_stylebox(border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 0.35)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = border_color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	return style

func _on_character_grid_tile_pressed(character_id: StringName) -> void:
	var cursor_index: int = _find_character_index(character_id)
	if cursor_index < 0:
		return

	if mouse_owner_player_number == 2:
		_set_character_select_player_active(2, true)
		_set_character_select_cursor_index(2, cursor_index)
		_set_character_select_player_selected(2, true)
		_set_character_select_locked(2, false)
		_select_character_option(p2_character_option, character_id)
		_on_character_option_changed(p2_character_option.selected)
		return

	_set_character_select_player_active(1, true)
	_set_character_select_cursor_index(1, cursor_index)
	_set_character_select_player_selected(1, true)
	_set_character_select_locked(1, false)
	_select_character_option(p1_character_option, character_id)
	_on_character_option_changed(p1_character_option.selected)

func _get_character_display_name(character_id: StringName) -> String:
	var option: Dictionary = character_options_by_id.get(character_id, {})
	if option.is_empty():
		return String(character_id)
	return String(option.get("display_name", String(character_id)))

func _reset_character_select_player_state() -> void:
	character_select_player_state.clear()
	character_select_device_to_player.clear()
	character_select_axis_hold_by_device.clear()
	character_select_prev_locked_state[1] = false
	character_select_prev_locked_state[2] = false
	for player_number in PLAYER_SLOT_IDS:
		character_select_player_state[player_number] = {
			"active": false,
			"locked": false,
			"selected": false,
			"cursor_index": _get_selected_index_for_player(player_number),
			"device_id": -1,
		}
	_refresh_character_previews()

func _get_selected_index_for_player(player_number: int) -> int:
	var option: OptionButton = p2_character_option if player_number == 2 else p1_character_option
	if option == null:
		return 0
	if option.selected >= 0 and option.selected < character_ids_by_index.size():
		return option.selected
	return 0

func _find_character_index(character_id: StringName) -> int:
	for index in character_ids_by_index.size():
		if character_ids_by_index[index] == character_id:
			return index
	return -1

func _handle_character_select_controller_button(button_event: InputEventJoypadButton) -> bool:
	if not button_event.pressed:
		return false

	var existing_player: int = _get_character_select_player_for_device(button_event.device)
	if existing_player <= 0:
		_get_or_join_character_select_player_for_device(button_event.device)
		# First press only joins/activates this selector; gameplay actions start on next press.
		return true

	var player_number: int = existing_player
	if player_number <= 0:
		return false

	var state: Dictionary = character_select_player_state.get(player_number, {})
	if state.is_empty():
		return false

	match button_event.button_index:
		JOY_BUTTON_DPAD_LEFT:
			_move_character_select_cursor(player_number, -1, 0)
			return true
		JOY_BUTTON_DPAD_RIGHT:
			_move_character_select_cursor(player_number, 1, 0)
			return true
		JOY_BUTTON_DPAD_UP:
			_move_character_select_cursor(player_number, 0, -1)
			return true
		JOY_BUTTON_DPAD_DOWN:
			_move_character_select_cursor(player_number, 0, 1)
			return true
		JOY_BUTTON_A:
			_lock_character_select_choice(player_number)
			return true
		JOY_BUTTON_B:
			if _is_character_player_locked(player_number):
				_unlock_character_select_choice(player_number)
			else:
				_on_back_to_main_menu_button_pressed()
			return true
		JOY_BUTTON_START:
			if _can_controller_shortcut_start_match():
				_on_start_match_button_pressed()
			return true

	return true

func _handle_character_select_controller_motion(motion_event: InputEventJoypadMotion) -> bool:
	var player_number: int = _get_character_select_player_for_device(motion_event.device)
	if player_number <= 0:
		var wake_motion: bool = absf(motion_event.axis_value) >= CONTROLLER_MENU_NAV_DEADZONE
		if not wake_motion:
			return false

		_get_or_join_character_select_player_for_device(motion_event.device)
		# First motion only wakes/assigns this selector; movement starts on next input.
		return true

	if player_number <= 0:
		return false

	var held: Dictionary = character_select_axis_hold_by_device.get(motion_event.device, {
		"left": false,
		"right": false,
		"up": false,
		"down": false,
	})

	var consumed := false
	if motion_event.axis == JOY_AXIS_LEFT_X:
		if motion_event.axis_value <= -CONTROLLER_MENU_NAV_DEADZONE:
			if not bool(held.get("left", false)):
				held["left"] = true
				_move_character_select_cursor(player_number, -1, 0)
				consumed = true
		else:
			held["left"] = false

		if motion_event.axis_value >= CONTROLLER_MENU_NAV_DEADZONE:
			if not bool(held.get("right", false)):
				held["right"] = true
				_move_character_select_cursor(player_number, 1, 0)
				consumed = true
		else:
			held["right"] = false

	if motion_event.axis == JOY_AXIS_LEFT_Y:
		if motion_event.axis_value <= -CONTROLLER_MENU_NAV_DEADZONE:
			if not bool(held.get("up", false)):
				held["up"] = true
				_move_character_select_cursor(player_number, 0, -1)
				consumed = true
		else:
			held["up"] = false

		if motion_event.axis_value >= CONTROLLER_MENU_NAV_DEADZONE:
			if not bool(held.get("down", false)):
				held["down"] = true
				_move_character_select_cursor(player_number, 0, 1)
				consumed = true
		else:
			held["down"] = false

	character_select_axis_hold_by_device[motion_event.device] = held
	return consumed

func _get_character_select_player_for_device(device_id: int) -> int:
	return int(character_select_device_to_player.get(device_id, 0))

func _get_or_join_character_select_player_for_device(device_id: int) -> int:
	var existing_player: int = _get_character_select_player_for_device(device_id)
	if existing_player > 0:
		return existing_player

	for player_number in PLAYER_SLOT_IDS:
		var state: Dictionary = character_select_player_state.get(player_number, {})
		if bool(state.get("active", false)):
			continue
		state["active"] = true
		state["locked"] = false
		state["selected"] = false
		state["device_id"] = device_id
		character_select_player_state[player_number] = state
		character_select_device_to_player[device_id] = player_number
		character_select_axis_hold_by_device[device_id] = {
			"left": false,
			"right": false,
			"up": false,
			"down": false,
		}
		_refresh_character_previews()
		return player_number

	return 0

func _set_character_select_cursor_index(player_number: int, cursor_index: int) -> void:
	if character_ids_by_index.is_empty():
		return

	var state: Dictionary = character_select_player_state.get(player_number, {})
	if state.is_empty():
		return

	var clamped_index := clampi(cursor_index, 0, character_ids_by_index.size() - 1)
	state["cursor_index"] = clamped_index
	character_select_player_state[player_number] = state
	_refresh_lock_status_panels()
	_refresh_character_grid_visuals()

func _set_character_select_locked(player_number: int, locked: bool) -> void:
	var state: Dictionary = character_select_player_state.get(player_number, {})
	if state.is_empty():
		return
	state["locked"] = locked
	character_select_player_state[player_number] = state

func _set_character_select_player_selected(player_number: int, selected: bool) -> void:
	var state: Dictionary = character_select_player_state.get(player_number, {})
	if state.is_empty():
		return
	state["selected"] = selected
	character_select_player_state[player_number] = state

func _set_character_select_player_active(player_number: int, active: bool) -> void:
	var state: Dictionary = character_select_player_state.get(player_number, {})
	if state.is_empty():
		return
	state["active"] = active
	character_select_player_state[player_number] = state

func _move_character_select_cursor(player_number: int, move_x: int, move_y: int) -> void:
	if character_ids_by_index.is_empty():
		return

	var state: Dictionary = character_select_player_state.get(player_number, {})
	if state.is_empty() or bool(state.get("locked", false)):
		return

	var total_items: int = character_ids_by_index.size()
	var current_index: int = int(state.get("cursor_index", 0))
	current_index = clampi(current_index, 0, total_items - 1)

	var columns: int = max(character_grid.columns, 1)
	var total_rows: int = int(ceili(float(total_items) / float(columns)))
	var current_row: int = current_index / columns
	var current_col: int = current_index % columns

	var target_row: int = clampi(current_row + move_y, 0, max(total_rows - 1, 0))
	var target_col: int = clampi(current_col + move_x, 0, columns - 1)

	var row_start: int = target_row * columns
	var row_end: int = min(row_start + columns - 1, total_items - 1)
	var target_index: int = clampi(row_start + target_col, row_start, row_end)

	state["cursor_index"] = target_index
	character_select_player_state[player_number] = state
	_refresh_lock_status_panels()
	_refresh_character_grid_visuals()

func _lock_character_select_choice(player_number: int) -> void:
	if character_ids_by_index.is_empty():
		return

	var state: Dictionary = character_select_player_state.get(player_number, {})
	if state.is_empty():
		return

	var cursor_index: int = int(state.get("cursor_index", 0))
	if cursor_index < 0 or cursor_index >= character_ids_by_index.size():
		return

	var character_id: StringName = character_ids_by_index[cursor_index]
	if player_number == 2:
		_select_character_option(p2_character_option, character_id)
	else:
		_select_character_option(p1_character_option, character_id)

	state["locked"] = true
	state["selected"] = true
	character_select_player_state[player_number] = state
	_refresh_character_previews()

func _unlock_character_select_choice(player_number: int) -> void:
	var state: Dictionary = character_select_player_state.get(player_number, {})
	if state.is_empty():
		return
	if not bool(state.get("locked", false)):
		return

	state["locked"] = false
	state["selected"] = false
	character_select_player_state[player_number] = state
	_refresh_character_previews()

func _refresh_character_grid_visuals() -> void:
	for index in character_grid_buttons.size():
		var tile: Button = character_grid_buttons[index]
		if tile == null:
			continue

		var p1_active := _is_character_player_active(1)
		var p2_active := _is_character_player_active(2)
		var p1_locked_state := _is_character_player_locked(1)
		var p2_locked_state := _is_character_player_locked(2)
		# Locked players hide their grid selector; lock state is represented by status panels.
		var p1_cursor := p1_active and not p1_locked_state and _get_character_player_cursor_index(1) == index
		var p2_cursor := p2_active and not p2_locked_state and _get_character_player_cursor_index(2) == index

		tile.self_modulate = CHARACTER_TILE_IDLE_COLOR
		if p1_cursor and p2_cursor:
			tile.self_modulate = PLAYER_CURSOR_COLOR_BOTH
		elif p1_cursor:
			tile.self_modulate = PLAYER_CURSOR_COLOR_P1
		elif p2_cursor:
			tile.self_modulate = PLAYER_CURSOR_COLOR_P2

		if index < character_display_names_by_index.size():
			tile.text = character_display_names_by_index[index]

func _refresh_lock_status_panels() -> void:
	var p1_locked: bool = _is_character_player_locked(1)
	var p2_locked: bool = _is_character_player_locked(2)
	var p1_active: bool = _is_character_player_active(1)
	var p2_active: bool = _is_character_player_active(2)
	var p1_name: String = _get_character_name_for_index(_get_character_player_cursor_index(1))
	var p2_name: String = _get_character_name_for_index(_get_character_player_cursor_index(2))

	if not p1_active:
		p1_lock_label.text = "Press any button to join"
	elif p1_locked:
		p1_lock_label.text = "P1 %s" % p1_name
	else:
		p1_lock_label.text = "P1 %s" % p1_name

	if not p2_active:
		p2_lock_label.text = "Press any button to join"
	elif p2_locked:
		p2_lock_label.text = "P2 %s" % p2_name
	else:
		p2_lock_label.text = "P2 %s" % p2_name

	_apply_lock_panel_visual(1, p1_lock_panel, p1_lock_label, p1_locked)
	_apply_lock_panel_visual(2, p2_lock_panel, p2_lock_label, p2_locked)

	if p1_locked and not bool(character_select_prev_locked_state.get(1, false)):
		_play_lock_panel_pulse(1, p1_lock_panel)
	if p2_locked and not bool(character_select_prev_locked_state.get(2, false)):
		_play_lock_panel_pulse(2, p2_lock_panel)

	character_select_prev_locked_state[1] = p1_locked
	character_select_prev_locked_state[2] = p2_locked

func _initialize_lock_panel_style_cache() -> void:
	character_select_lock_panel_style_cache = {
		1: {
			"locked": _build_lock_panel_stylebox(PLAYER_LOCK_COLOR_P1, PLAYER_LOCK_COLOR_P1.darkened(0.35)),
			"unlocked": _build_lock_panel_stylebox(PLAYER_LOCK_PANEL_IDLE_COLOR, PLAYER_LOCK_PANEL_IDLE_BORDER_COLOR),
		},
		2: {
			"locked": _build_lock_panel_stylebox(PLAYER_LOCK_COLOR_P2, PLAYER_LOCK_COLOR_P2.darkened(0.35)),
			"unlocked": _build_lock_panel_stylebox(PLAYER_LOCK_PANEL_IDLE_COLOR, PLAYER_LOCK_PANEL_IDLE_BORDER_COLOR),
		},
	}
	character_select_lock_panel_applied_state[1] = null
	character_select_lock_panel_applied_state[2] = null

func _build_lock_panel_stylebox(bg_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = border_color
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	return style

func _apply_lock_panel_visual(player_number: int, panel: PanelContainer, label: Label, locked: bool) -> void:
	if panel == null or label == null:
		return

	var previous_locked_state = character_select_lock_panel_applied_state.get(player_number, null)
	if previous_locked_state == null or bool(previous_locked_state) != locked:
		var styles_for_player: Dictionary = character_select_lock_panel_style_cache.get(player_number, {})
		var style_key := "locked" if locked else "unlocked"
		var style: StyleBoxFlat = styles_for_player.get(style_key, null)
		if style != null:
			panel.add_theme_stylebox_override("panel", style)
		character_select_lock_panel_applied_state[player_number] = locked

	label.self_modulate = PLAYER_LOCK_PANEL_TEXT_COLOR

func _play_lock_panel_pulse(player_number: int, panel: PanelContainer) -> void:
	if panel == null:
		return

	var existing_tween: Tween = character_select_lock_pulse_tweens.get(player_number, null)
	if existing_tween != null:
		existing_tween.kill()

	# Scale around panel center so pulse expands evenly in all directions.
	panel.pivot_offset = panel.size * 0.5
	panel.scale = Vector2.ONE
	var tween := create_tween()
	tween.tween_property(panel, "scale", Vector2(1.05, 1.05), 0.08)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.1)
	character_select_lock_pulse_tweens[player_number] = tween

func _get_character_name_for_index(index: int) -> String:
	if index < 0 or index >= character_ids_by_index.size():
		return "Unknown"
	return _get_character_display_name(character_ids_by_index[index])

func _is_character_player_active(player_number: int) -> bool:
	var state: Dictionary = character_select_player_state.get(player_number, {})
	return bool(state.get("active", false))

func _is_character_player_locked(player_number: int) -> bool:
	var state: Dictionary = character_select_player_state.get(player_number, {})
	return bool(state.get("locked", false))

func _can_controller_shortcut_start_match() -> bool:
	for player_number in PLAYER_SLOT_IDS:
		if not _is_character_player_active(player_number):
			return false
		if not _is_character_player_locked(player_number):
			return false
	return _is_controller_assignment_valid_for_match_start()

func _can_keyboard_shortcut_start_match() -> bool:
	if not _has_valid_character_selection_for_players():
		return false
	return _is_controller_assignment_valid_for_match_start()

func _has_valid_character_selection_for_players() -> bool:
	if character_ids_by_index.is_empty():
		return false
	if not _is_character_player_active(1) or not _is_character_player_active(2):
		return false
	if not _is_character_player_selected(1) or not _is_character_player_selected(2):
		return false

	var p1_character: StringName = _get_selected_character_id(p1_character_option)
	var p2_character: StringName = _get_selected_character_id(p2_character_option)
	return p1_character != &"" and p2_character != &""

func _refresh_character_select_hint_label() -> void:
	if character_select_hint_label == null:
		return

	if _can_controller_shortcut_start_match() or _can_keyboard_shortcut_start_match():
		character_select_hint_label.text = CHARACTER_SELECT_HINT_READY
		return

	character_select_hint_label.text = CHARACTER_SELECT_HINT_DEFAULT

func _get_character_player_cursor_index(player_number: int) -> int:
	var state: Dictionary = character_select_player_state.get(player_number, {})
	return int(state.get("cursor_index", -1))

func _is_character_player_selected(player_number: int) -> bool:
	var state: Dictionary = character_select_player_state.get(player_number, {})
	return bool(state.get("selected", false))

func _on_character_option_changed(_index: int) -> void:
	_refresh_character_previews()

func _on_start_match_button_pressed() -> void:
	if not _is_controller_assignment_valid_for_match_start():
		_refresh_start_match_availability()
		return
	_sync_character_select_controller_assignments_to_match_setup()

	match_start_requested.emit(
		_get_selected_character_id(p1_character_option),
		_get_selected_character_id(p2_character_option)
	)

func _get_character_select_assigned_device_id(player_number: int) -> int:
	var state: Dictionary = character_select_player_state.get(player_number, {})
	if state.is_empty():
		return -1
	return int(state.get("device_id", -1))

func _sync_character_select_controller_assignments_to_match_setup() -> void:
	var match_setup: Node = get_node_or_null(MATCH_SETUP_NODE_PATH)
	if match_setup == null:
		return

	if p1_uses_controller:
		match_setup.set_player_controller_device_id(1, _get_character_select_assigned_device_id(1))
	if p2_uses_controller:
		match_setup.set_player_controller_device_id(2, _get_character_select_assigned_device_id(2))

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
	_refresh_controller_assignment_warning()

func _on_p1_controller_input_button_pressed() -> void:
	p1_uses_controller = true
	_save_input_modes_to_match_setup()
	_clear_pending_rebind()
	_refresh_input_mode_switch_visuals()
	_refresh_control_binding_button_texts()
	_refresh_controller_assignment_warning()

func _on_p2_keyboard_input_button_pressed() -> void:
	p2_uses_controller = false
	_save_input_modes_to_match_setup()
	_clear_pending_rebind()
	_refresh_input_mode_switch_visuals()
	_refresh_control_binding_button_texts()
	_refresh_controller_assignment_warning()

func _on_p2_controller_input_button_pressed() -> void:
	p2_uses_controller = true
	_save_input_modes_to_match_setup()
	_clear_pending_rebind()
	_refresh_input_mode_switch_visuals()
	_refresh_control_binding_button_texts()
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

func _can_accept_controller_rebind_event(_event_device_id: int, _player_number: int) -> bool:
	# Controller device ownership is selected in Character Select, so Controls rebind accepts any active joypad.
	return true

func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if not connected:
		_remove_character_select_device_assignment(device)
	_refresh_controller_assignment_warning()
	_refresh_start_match_availability()
	if main_menu_screen.visible:
		_focus_default_for_visible_menu()
	_refresh_main_menu_button_selection_visuals()

func _remove_character_select_device_assignment(device_id: int) -> void:
	var player_number: int = _get_character_select_player_for_device(device_id)
	if player_number <= 0:
		return

	character_select_device_to_player.erase(device_id)
	character_select_axis_hold_by_device.erase(device_id)

	var state: Dictionary = character_select_player_state.get(player_number, {})
	if state.is_empty():
		return
	state["active"] = false
	state["locked"] = false
	state["selected"] = false
	state["device_id"] = -1
	character_select_player_state[player_number] = state
	_refresh_character_previews()

func _refresh_start_match_availability() -> void:
	_refresh_character_select_hint_label()

	var controller_assignment_error: String = _get_match_start_controller_assignment_error()
	var can_start: bool = controller_assignment_error.is_empty()
	start_match_button.disabled = not can_start

func _get_match_start_controller_assignment_error() -> String:
	var connected_devices: PackedInt32Array = Input.get_connected_joypads()
	var p1_device: int = -1
	var p2_device: int = -1

	if p1_uses_controller:
		p1_device = _get_character_select_assigned_device_id(1)
		if p1_device < 0:
			return "Cannot start: Player 1 is set to controller mode but has not joined with a controller in Character Select."
		if not connected_devices.has(p1_device):
			return "Cannot start: Player 1's selected controller is not connected."

	if p2_uses_controller:
		p2_device = _get_character_select_assigned_device_id(2)
		if p2_device < 0:
			return "Cannot start: Player 2 is set to controller mode but has not joined with a controller in Character Select."
		if not connected_devices.has(p2_device):
			return "Cannot start: Player 2's selected controller is not connected."

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
		_focus_default_controls_menu_item()
		return
	if character_select_screen.visible:
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

func _focus_default_controls_menu_item() -> void:
	var focus_owner: Control = get_viewport().gui_get_focus_owner()
	if focus_owner != null and controls_screen.is_ancestor_of(focus_owner) and focus_owner.is_visible_in_tree():
		return

	var current_tab: int = controls_player_tabs.current_tab
	var prefers_controller: bool = p1_uses_controller if current_tab == 0 else p2_uses_controller
	var preferred_input_mode_button: Button
	if current_tab == 0:
		preferred_input_mode_button = p1_controller_input_button if prefers_controller else p1_keyboard_input_button
	else:
		preferred_input_mode_button = p2_controller_input_button if prefers_controller else p2_keyboard_input_button
	if preferred_input_mode_button != null:
		preferred_input_mode_button.grab_focus()
		return

	var fallback_button: Button = controls_back_button
	fallback_button.grab_focus()

func _switch_controls_tab(direction: int) -> void:
	if controls_player_tabs == null or controls_player_tabs.get_tab_count() <= 0:
		return

	var tab_count: int = controls_player_tabs.get_tab_count()
	var next_tab: int = controls_player_tabs.current_tab + direction
	if next_tab < 0:
		next_tab = tab_count - 1
	elif next_tab >= tab_count:
		next_tab = 0

	controls_player_tabs.current_tab = next_tab
	call_deferred("_focus_default_controls_menu_item")

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
