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
@onready var select_scroll = $CharacterSelectScreen/SelectScroll
@onready var p1_character_option = $CharacterSelectScreen/SelectScroll/SelectContent/P1Row/P1CharacterOption
@onready var p2_character_option = $CharacterSelectScreen/SelectScroll/SelectContent/P2Row/P2CharacterOption
@onready var p1_preview_label = $CharacterSelectScreen/SelectScroll/SelectContent/P1PreviewLabel
@onready var p2_preview_label = $CharacterSelectScreen/SelectScroll/SelectContent/P2PreviewLabel
@onready var start_match_button = $CharacterSelectScreen/SelectScroll/SelectContent/StartMatchButton
@onready var back_to_main_menu_button = $CharacterSelectScreen/SelectScroll/SelectContent/BackToMainMenuButton
@onready var controls_background = $ControlsBackground
@onready var controls_screen = $ControlsScreen
@onready var controls_player_tabs = $ControlsScreen/ControlsContent/PlayerTabs
@onready var controls_back_button = $ControlsScreen/ControlsContent/BackButton
@onready var p1_keyboard_input_button = $ControlsScreen/ControlsContent/PlayerTabs/Player1Tab/P1InputModeRow/P1InputModeSwitch/KeyboardButton
@onready var p1_controller_input_button = $ControlsScreen/ControlsContent/PlayerTabs/Player1Tab/P1InputModeRow/P1InputModeSwitch/ControllerButton
@onready var p2_keyboard_input_button = $ControlsScreen/ControlsContent/PlayerTabs/Player2Tab/P2InputModeRow/P2InputModeSwitch/KeyboardButton
@onready var p2_controller_input_button = $ControlsScreen/ControlsContent/PlayerTabs/Player2Tab/P2InputModeRow/P2InputModeSwitch/ControllerButton

var character_ids_by_index: Array[StringName] = []
var character_options_by_id := {}
var cached_character_options: Array = []
var cached_default_p1: StringName = &"default_fighter"
var cached_default_p2: StringName = &"default_fighter"
var p1_uses_controller := false
var p2_uses_controller := false

const CONTROLS_TAB_TITLE_P1_KEY := "UI_TAB_PLAYER_1"
const CONTROLS_TAB_TITLE_P2_KEY := "UI_TAB_PLAYER_2"

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
	_refresh_controls_tab_titles()
	_refresh_input_mode_switch_visuals()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh_controls_tab_titles()

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
	main_menu_background.hide()
	main_menu_screen.hide()
	character_select_background.hide()
	character_select_screen.hide()
	hide_winner()

func hide_controls_screen() -> void:
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
	select_scroll.scroll_vertical = 0
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
