extends CharacterBody2D

class_name Player

signal health_changed(player_number: int, health: float, max_health: float)
signal defeated(player_number: int)
signal move_requested(player_number: int, move_id: StringName, grounded: bool, directional_intent: Vector2i)

class InputIntent:
	var move_axis: int = 0
	var directional_intent: Vector2i = Vector2i.ZERO
	var jump_pressed: bool = false
	var jump_held: bool = false
	var down_tap: bool = false
	var attack_pressed: bool = false

const DEFAULT_MOVE_EXECUTOR_SCRIPT: Script = preload("res://scripts/characters/default_move_executor.gd")
const MOVE_DATA_SCRIPT: Script = preload("res://scripts/characters/move_data.gd")
const DEFAULT_CHARACTER_ID := "default_fighter"
const SPEED_CHARACTER_ID := "speed_fighter"

@export var character_profile: CharacterData

@export var speed = 400.0
@export var ground_acceleration = 3000.0
@export var ground_deceleration = 2500.0
@export var air_acceleration = 850.0
@export var air_deceleration = 350.0
@export var air_release_deceleration = 700.0
@export var air_reverse_acceleration = 1100.0
@export var max_air_speed_factor = 0.92
@export var max_air_reverse_speed_factor = 0.72
@export var jump_force = -600.0
@export var max_jumps = 2
@export var double_jump_force = -560.0
@export var double_jump_hold_factor = 0.55
@export var double_jump_control_time = 0.25
@export var double_jump_air_acceleration = 1250.0
@export var double_jump_air_reverse_acceleration = 1450.0
@export var double_jump_direction_speed_factor = 0.9
@export var double_jump_burst_acceleration = 220.0
@export var double_jump_reverse_burst_acceleration = 360.0
@export var gravity = 2000.0
@export var max_fall_speed = 950.0
@export var fast_fall_speed = 1450.0
@export var fast_fall_gravity_multiplier = 1.5
@export var max_jump_hold_time = 0.13
@export var held_jump_gravity_multiplier = 0.31
@export var short_hop_velocity_multiplier = 0.62
@export var max_health = 100.0
@export var attack_damage = 10.0
@export var attack_cooldown = 0.5
@export var damage_flash_duration = 0.12
@export var show_directional_intent_debug := true

var health: float
var is_attacking = false
var attack_timer = 0.0
var current_move_damage = 0.0
var player_number = 1
var facing_dir = 1
var is_damage_flashing = false
var jump_hold_timer = 0.0
var jump_count = 0
var double_jump_control_timer = 0.0
var is_fast_falling = false
var directional_intent_debug_label: Label

@onready var sprite = $Sprite
@onready var attack_hitbox = $AttackHitbox
@onready var attack_collision = $AttackHitbox/AttackCollision
@onready var attack_debug_fill = $AttackHitbox/AttackDebugFill
@onready var attack_debug_outline = $AttackHitbox/AttackDebugOutline
@onready var move_executor = $MoveExecutor

var current_animation = "idle"
var fallback_move_data

func _ready():
	# Prevent stacking on another moving fighter from inheriting platform velocity.
	# This keeps horizontal motion relative to world movement, not other players.
	platform_floor_layers = 0
	_ensure_directional_intent_debug_label()
	_apply_character_profile()
	health = max_health
	if attack_hitbox:
		attack_hitbox.body_entered.connect(_on_attack_hitbox_entered)
	if attack_debug_fill:
		attack_debug_fill.hide()
	if attack_debug_outline:
		attack_debug_outline.hide()
	if not sprite:
		sprite = $Sprite
	_ensure_move_executor()
	fallback_move_data = _build_fallback_move_data()

func _apply_character_profile():
	if character_profile == null:
		return

	max_health = character_profile.max_health
	speed = character_profile.speed
	ground_acceleration = character_profile.ground_acceleration
	ground_deceleration = character_profile.ground_deceleration
	air_acceleration = character_profile.air_acceleration
	air_deceleration = character_profile.air_deceleration
	air_release_deceleration = character_profile.air_release_deceleration
	air_reverse_acceleration = character_profile.air_reverse_acceleration
	max_air_speed_factor = character_profile.max_air_speed_factor
	max_air_reverse_speed_factor = character_profile.max_air_reverse_speed_factor
	jump_force = character_profile.jump_force
	max_jumps = character_profile.max_jumps
	double_jump_force = character_profile.double_jump_force
	double_jump_hold_factor = character_profile.double_jump_hold_factor
	double_jump_control_time = character_profile.double_jump_control_time
	double_jump_air_acceleration = character_profile.double_jump_air_acceleration
	double_jump_air_reverse_acceleration = character_profile.double_jump_air_reverse_acceleration
	double_jump_direction_speed_factor = character_profile.double_jump_direction_speed_factor
	double_jump_burst_acceleration = character_profile.double_jump_burst_acceleration
	double_jump_reverse_burst_acceleration = character_profile.double_jump_reverse_burst_acceleration
	gravity = character_profile.gravity
	max_fall_speed = character_profile.max_fall_speed
	fast_fall_speed = character_profile.fast_fall_speed
	fast_fall_gravity_multiplier = character_profile.fast_fall_gravity_multiplier
	max_jump_hold_time = character_profile.max_jump_hold_time
	held_jump_gravity_multiplier = character_profile.held_jump_gravity_multiplier
	short_hop_velocity_multiplier = character_profile.short_hop_velocity_multiplier
	attack_damage = character_profile.attack_damage * character_profile.strength_multiplier
	attack_cooldown = character_profile.attack_cooldown
	damage_flash_duration = character_profile.damage_flash_duration

func _physics_process(delta):
	var raw_input = get_input()
	var input_intent = _build_input_intent(raw_input)
	_update_directional_intent_debug_label(input_intent.directional_intent)

	# Handle movement with momentum and limited air turning.
	var input_dir: int = input_intent.move_axis

	if input_dir != 0 and not is_attacking:
		facing_dir = input_dir

	if is_on_floor():
		jump_count = 0
		double_jump_control_timer = 0.0
		is_fast_falling = false
	elif double_jump_control_timer > 0.0:
		double_jump_control_timer = max(double_jump_control_timer - delta, 0.0)

	if is_on_floor():
		var ground_target_speed: float = float(input_dir) * speed
		var ground_accel: float = ground_acceleration if input_dir != 0 else ground_deceleration
		velocity.x = move_toward(velocity.x, ground_target_speed, ground_accel * delta)
	else:
		var current_air_acceleration: float = air_acceleration
		var current_air_reverse_acceleration: float = air_reverse_acceleration
		var current_max_air_speed_factor: float = max_air_speed_factor
		if double_jump_control_timer > 0.0:
			current_air_acceleration = double_jump_air_acceleration
			current_air_reverse_acceleration = double_jump_air_reverse_acceleration
			current_max_air_speed_factor = max(current_max_air_speed_factor, double_jump_direction_speed_factor)

		var air_target_speed: float = float(input_dir) * speed * current_max_air_speed_factor
		if input_dir == 0:
			# Letting go of movement in-air should bleed momentum faster.
			velocity.x = move_toward(velocity.x, 0.0, air_release_deceleration * delta)
		elif signf(velocity.x) == 0.0 or signf(velocity.x) == float(input_dir):
			velocity.x = move_toward(velocity.x, air_target_speed, current_air_acceleration * delta)
		else:
			# Allow reversals in air, but cap reverse speed lower than forward air drift.
			var air_reverse_target_speed: float = float(input_dir) * speed * max_air_reverse_speed_factor
			velocity.x = move_toward(velocity.x, air_reverse_target_speed, current_air_reverse_acceleration * delta)

	var moving: bool = absf(velocity.x) > 10.0
	
	# Update animation state
	if not is_on_floor():
		update_animation("jump")
	elif is_attacking:
		update_animation("attack")
	elif moving:
		update_animation("walk")
	else:
		update_animation("idle")
	
	# Handle jump
	if input_intent.jump_pressed and jump_count < max_jumps:
		is_fast_falling = false
		if jump_count == 0:
			velocity.y = jump_force
			jump_hold_timer = max_jump_hold_time
		else:
			_perform_double_jump(input_dir)

		jump_count += 1
		update_animation("jump")
	
	# Fast-fall triggers only from a down tap while currently descending.
	if not is_on_floor() and velocity.y > 0.0 and input_intent.down_tap:
		is_fast_falling = true

	# Apply gravity
	if not is_on_floor():
		# Releasing jump early creates a short hop.
		if velocity.y < 0 and not input_intent.jump_held and jump_hold_timer > 0.0:
			velocity.y *= short_hop_velocity_multiplier
			jump_hold_timer = 0.0

		if velocity.y < 0 and input_intent.jump_held and jump_hold_timer > 0.0:
			velocity.y += gravity * held_jump_gravity_multiplier * delta
			jump_hold_timer -= delta
		else:
			var fall_gravity_multiplier: float = fast_fall_gravity_multiplier if is_fast_falling else 1.0
			velocity.y += gravity * fall_gravity_multiplier * delta
			jump_hold_timer = 0.0

		var current_max_fall_speed: float = fast_fall_speed if is_fast_falling else max_fall_speed
		velocity.y = min(velocity.y, current_max_fall_speed)
	elif velocity.y > 0:
		velocity.y = 0
	
	# Handle attack
	if input_intent.attack_pressed and attack_timer <= 0.0 and not is_attacking:
		var move_data: MoveData = _resolve_move_data(input_intent)
		move_requested.emit(player_number, move_data.move_id, is_on_floor(), input_intent.directional_intent)
		_configure_attack_hitbox_for_move(move_data, is_on_floor(), input_intent.directional_intent)
		current_move_damage = move_data.damage
		move_executor.execute_move(self, move_data)
		attack_timer = move_data.cooldown
	
	attack_timer = max(attack_timer - delta, 0.0)
	
	# Flip sprite based on one shared facing convention.
	if sprite:
		sprite.scale.x = float(facing_dir)

	move_and_slide()

func get_input() -> Dictionary:
	if player_number == 1:
		return {
			"left": Input.is_action_pressed("ui_left_p1"),
			"right": Input.is_action_pressed("ui_right_p1"),
			"up_held": Input.is_action_pressed("ui_up_p1"),
			"down_held": _is_action_pressed_safe("ui_down_p1"),
			"jump": _is_action_just_pressed_safe("jump_p1"),
			"jump_hold": _is_action_pressed_safe("jump_p1"),
			"down_tap": _is_action_just_pressed_safe("ui_down_p1"),
			"attack": Input.is_action_just_pressed("attack_p1")
		}
	else:
		return {
			"left": Input.is_action_pressed("ui_left_p2"),
			"right": Input.is_action_pressed("ui_right_p2"),
			"up_held": Input.is_action_pressed("ui_up_p2"),
			"down_held": _is_action_pressed_safe("ui_down_p2"),
			"jump": _is_action_just_pressed_safe("jump_p2"),
			"jump_hold": _is_action_pressed_safe("jump_p2"),
			"down_tap": _is_action_just_pressed_safe("ui_down_p2"),
			"attack": Input.is_action_just_pressed("attack_p2")
		}

func _build_input_intent(raw_input: Dictionary) -> InputIntent:
	var intent = InputIntent.new()
	var left_held: bool = bool(raw_input.get("left", false))
	var right_held: bool = bool(raw_input.get("right", false))
	var up_held: bool = bool(raw_input.get("up_held", false))
	var down_held: bool = bool(raw_input.get("down_held", false))
	var jump_held: bool = bool(raw_input.get("jump_hold", false))

	intent.move_axis = _axis_from_directions(left_held, right_held)

	# Prioritize vertical directional intent for attacks over horizontal intent.
	var vertical_axis: int = 0
	if up_held and not down_held:
		vertical_axis = -1
	elif down_held and not up_held:
		vertical_axis = 1
	elif down_held:
		vertical_axis = 1
	elif up_held:
		vertical_axis = -1

	var horizontal_attack_axis: int = 0 if vertical_axis != 0 else intent.move_axis
	intent.directional_intent = Vector2i(horizontal_attack_axis, vertical_axis)
	intent.jump_pressed = bool(raw_input.get("jump", false))
	intent.jump_held = jump_held
	intent.down_tap = bool(raw_input.get("down_tap", false))
	intent.attack_pressed = bool(raw_input.get("attack", false))
	return intent

func _axis_from_directions(negative: bool, positive: bool) -> int:
	if negative == positive:
		return 0
	return -1 if negative else 1

func _ensure_move_executor():
	if move_executor:
		return

	move_executor = DEFAULT_MOVE_EXECUTOR_SCRIPT.new()
	move_executor.name = "MoveExecutor"
	add_child(move_executor)

func _build_fallback_move_data() -> MoveData:
	var move_data: MoveData = MOVE_DATA_SCRIPT.new()
	move_data.move_id = &"neutral"
	move_data.display_name = "Fallback Neutral"
	move_data.damage = attack_damage
	move_data.cooldown = attack_cooldown
	move_data.startup_frames = 4
	move_data.active_frames = 3
	move_data.endlag_frames = 12
	return move_data

func _resolve_move_data(input_intent: InputIntent) -> MoveData:
	var is_grounded: bool = is_on_floor()
	var directional_move: MoveData = _resolve_directional_move_slot(input_intent.directional_intent, is_grounded)
	if directional_move != null:
		return directional_move

	if character_profile:
		if is_grounded and character_profile.ground_neutral_move:
			return character_profile.ground_neutral_move
		if not is_grounded and character_profile.air_neutral_move:
			return character_profile.air_neutral_move

	# Keep using current attack tuning if no character move data is assigned yet.
	fallback_move_data.damage = attack_damage
	fallback_move_data.cooldown = attack_cooldown
	return fallback_move_data

func _resolve_directional_move_slot(directional_intent: Vector2i, is_grounded: bool) -> MoveData:
	if character_profile == null:
		return null

	# Vertical intent has priority over horizontal intent.
	if directional_intent.y < 0:
		return character_profile.ground_up_move if is_grounded else character_profile.air_up_move
	if directional_intent.y > 0:
		return character_profile.ground_down_move if is_grounded else character_profile.air_down_move

	if directional_intent.x == 0:
		return null

	var is_forward: bool = directional_intent.x == facing_dir
	if is_forward:
		return character_profile.ground_forward_move if is_grounded else character_profile.air_forward_move
	return character_profile.ground_back_move if is_grounded else character_profile.air_back_move

func _is_action_just_pressed_safe(action_name: String) -> bool:
	return InputMap.has_action(action_name) and Input.is_action_just_pressed(action_name)

func _is_action_pressed_safe(action_name: String) -> bool:
	return InputMap.has_action(action_name) and Input.is_action_pressed(action_name)

func _ensure_directional_intent_debug_label() -> void:
	if not show_directional_intent_debug:
		return

	directional_intent_debug_label = Label.new()
	directional_intent_debug_label.name = "DirectionalIntentDebug"
	directional_intent_debug_label.position = Vector2(0.0, -98.0)
	directional_intent_debug_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	directional_intent_debug_label.modulate = Color(0.9, 1.0, 0.9, 1.0)
	add_child(directional_intent_debug_label)

func _update_directional_intent_debug_label(directional_intent: Vector2i) -> void:
	if directional_intent_debug_label == null:
		return

	directional_intent_debug_label.text = "P%d Intent: (%d, %d)" % [player_number, directional_intent.x, directional_intent.y]

func _perform_double_jump(input_dir: int):
	velocity.y = double_jump_force
	jump_hold_timer = max_jump_hold_time * double_jump_hold_factor
	double_jump_control_timer = double_jump_control_time

	var jump_dir: int = input_dir
	if jump_dir == 0:
		jump_dir = int(signf(velocity.x))

	if jump_dir != 0:
		if not is_attacking:
			facing_dir = jump_dir
		var target_speed: float = float(jump_dir) * speed * double_jump_direction_speed_factor
		var turning_around: bool = signf(velocity.x) != 0.0 and signf(velocity.x) != float(jump_dir)
		var burst_acceleration: float = double_jump_reverse_burst_acceleration if turning_around else double_jump_burst_acceleration
		velocity.x = move_toward(velocity.x, target_speed, burst_acceleration)

func _configure_attack_hitbox_for_move(move_data: MoveData, is_grounded: bool, directional_intent: Vector2i) -> void:
	if attack_collision == null:
		return

	if is_grounded:
		_set_attack_hitbox_rect(Vector2(100.0, 64.0), Vector2(82.0 * facing_dir, -32.0))
		return

	var character_id: String = String(character_profile.character_id) if character_profile else DEFAULT_CHARACTER_ID
	var use_speed_layout: bool = character_id == SPEED_CHARACTER_ID

	# Use captured directional input for placeholder aerial hitbox direction.
	if directional_intent.y < 0:
		if use_speed_layout:
			_set_attack_hitbox_rect(Vector2(62.0, 52.0), Vector2(0.0, -100.0))
		else:
			_set_attack_hitbox_rect(Vector2(70.0, 56.0), Vector2(0.0, -94.0))
		return

	if directional_intent.y > 0:
		if use_speed_layout:
			_set_attack_hitbox_rect(Vector2(62.0, 52.0), Vector2(0.0, 30.0))
		else:
			_set_attack_hitbox_rect(Vector2(70.0, 56.0), Vector2(0.0, 26.0))
		return

	if directional_intent.x != 0:
		var forward_sign: float = 1.0 if directional_intent.x == facing_dir else -1.0
		var local_sign: float = forward_sign * float(facing_dir)
		if use_speed_layout:
			var width: float = 108.0 if forward_sign > 0.0 else 100.0
			_set_attack_hitbox_rect(Vector2(width, 44.0), Vector2(88.0 * local_sign, -32.0))
		else:
			var default_width: float = 94.0 if forward_sign > 0.0 else 90.0
			_set_attack_hitbox_rect(Vector2(default_width, 54.0), Vector2(78.0 * local_sign, -32.0))
		return

	# Neutral aerial attack: all-around placeholder hitbox centered on player.
	if use_speed_layout:
		_set_attack_hitbox_rect(Vector2(84.0, 84.0), Vector2(0.0, -32.0))
	else:
		_set_attack_hitbox_rect(Vector2(92.0, 92.0), Vector2(0.0, -32.0))

func _set_attack_hitbox_rect(size: Vector2, center: Vector2) -> void:
	var rect_shape := attack_collision.shape as RectangleShape2D
	if rect_shape == null:
		rect_shape = RectangleShape2D.new()
		attack_collision.shape = rect_shape

	rect_shape.size = size
	attack_collision.position = center
	_update_attack_debug_geometry(size, center)

func _update_attack_debug_geometry(size: Vector2, center: Vector2) -> void:
	if attack_debug_fill:
		attack_debug_fill.offset_left = center.x - size.x * 0.5
		attack_debug_fill.offset_top = center.y - size.y * 0.5
		attack_debug_fill.offset_right = center.x + size.x * 0.5
		attack_debug_fill.offset_bottom = center.y + size.y * 0.5

	if attack_debug_outline:
		var left := center.x - size.x * 0.5
		var top := center.y - size.y * 0.5
		var right := center.x + size.x * 0.5
		var bottom := center.y + size.y * 0.5
		attack_debug_outline.points = PackedVector2Array([
			Vector2(left, top),
			Vector2(right, top),
			Vector2(right, bottom),
			Vector2(left, bottom),
			Vector2(left, top),
		])

func begin_attack_state():
	is_attacking = true
	update_animation("attack")

func set_attack_hitbox_enabled(enabled: bool):
	if attack_hitbox:
		attack_hitbox.monitoring = enabled
	if attack_debug_fill:
		attack_debug_fill.visible = enabled
	if attack_debug_outline:
		attack_debug_outline.visible = enabled

func end_attack_state():
	is_attacking = false
	current_move_damage = 0.0
	set_attack_hitbox_enabled(false)
	if sprite:
		sprite.scale.y = 1.0

func update_animation(anim_name: String):
	if current_animation == anim_name:
		return
	
	current_animation = anim_name
	_apply_animation_visuals(anim_name)

func _apply_animation_visuals(anim_name: String):
	if not sprite:
		return

	# Keep the hurt flash color active for the full flash duration.
	if not is_damage_flashing:
		match anim_name:
			"idle":
				sprite.color = Color.WHITE
			"walk":
				sprite.color = Color(1.0, 1.0, 0.8)  # Slightly yellow tint
			"jump":
				sprite.color = Color(0.8, 1.0, 1.0)  # Slightly cyan tint
			"attack":
				sprite.color = Color(1.0, 0.6, 0.6)  # Attack tint

	if anim_name == "attack":
		sprite.scale.y = 1.1  # Slight scaling for visual feedback
	else:
		sprite.scale.y = 1.0

func _on_attack_hitbox_entered(body):
	if body is Player and body != self:
		var applied_damage: float = current_move_damage if current_move_damage > 0.0 else attack_damage
		body.take_damage(applied_damage)
		print("Player %d hit Player %d for %.1f damage!" % [player_number, body.player_number, applied_damage])

func take_damage(damage: float):
	health -= damage
	health = max(0, health)
	health_changed.emit(player_number, health, max_health)
	_start_damage_flash()
	
	if health <= 0:
		defeated.emit(player_number)
		die()

func _start_damage_flash():
	if not sprite or is_queued_for_deletion():
		return

	is_damage_flashing = true
	sprite.color = Color(0.8, 0.2, 0.2)  # Deeper red than attack tint.
	await get_tree().create_timer(damage_flash_duration).timeout

	if is_queued_for_deletion():
		return

	is_damage_flashing = false
	_apply_animation_visuals(current_animation)

func die():
	print("Player %d defeated!" % player_number)
	queue_free()

func set_player_number(num: int):
	player_number = num
	if num == 1:
		facing_dir = 1
	else:
		facing_dir = -1
