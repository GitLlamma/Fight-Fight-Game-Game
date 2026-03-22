extends CharacterBody2D

class_name Player

signal health_changed(player_number: int, health: float, max_health: float)
signal defeated(player_number: int)

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

var health: float
var is_attacking = false
var attack_timer = 0.0
var player_number = 1
var facing_dir := 1
var is_damage_flashing := false
var jump_hold_timer := 0.0
var jump_count := 0
var double_jump_control_timer := 0.0
var is_fast_falling := false

@onready var sprite = $Sprite
@onready var attack_hitbox = $AttackHitbox
@onready var attack_debug_fill = $AttackHitbox/AttackDebugFill
@onready var attack_debug_outline = $AttackHitbox/AttackDebugOutline

var current_animation = "idle"

func _ready():
	health = max_health
	if attack_hitbox:
		attack_hitbox.body_entered.connect(_on_attack_hitbox_entered)
	if attack_debug_fill:
		attack_debug_fill.hide()
	if attack_debug_outline:
		attack_debug_outline.hide()
	if not sprite:
		sprite = $Sprite

func _physics_process(delta):
	var input = get_input()

	# Handle movement with momentum and limited air turning.
	var input_dir: int = 0
	if input["left"]:
		input_dir -= 1
	if input["right"]:
		input_dir += 1

	if input_dir != 0:
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

	var moving := absf(velocity.x) > 10.0
	
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
	if input["jump"] and jump_count < max_jumps:
		is_fast_falling = false
		if jump_count == 0:
			velocity.y = jump_force
			jump_hold_timer = max_jump_hold_time
		else:
			_perform_double_jump(input_dir)

		jump_count += 1
		update_animation("jump")
	
	# Fast-fall triggers only from a down tap while currently descending.
	if not is_on_floor() and velocity.y > 0.0 and input["down_tap"]:
		is_fast_falling = true

	# Apply gravity
	if not is_on_floor():
		# Releasing jump early creates a short hop.
		if velocity.y < 0 and not input["jump_hold"] and jump_hold_timer > 0.0:
			velocity.y *= short_hop_velocity_multiplier
			jump_hold_timer = 0.0

		if velocity.y < 0 and input["jump_hold"] and jump_hold_timer > 0.0:
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
	if input["attack"] and attack_timer <= 0:
		perform_attack()
		attack_timer = attack_cooldown
	
	attack_timer -= delta
	
	# Flip sprite based on one shared facing convention.
	if sprite:
		sprite.scale.x = float(facing_dir)

	# Mirror attack hitbox with visual facing so attack direction matches sprite.
	if attack_hitbox:
		attack_hitbox.scale.x = float(facing_dir)
	
	move_and_slide()

func get_input() -> Dictionary:
	if player_number == 1:
		return {
			"left": Input.is_action_pressed("ui_left_p1"),
			"right": Input.is_action_pressed("ui_right_p1"),
			"jump": Input.is_action_just_pressed("ui_up_p1"),
			"jump_hold": Input.is_action_pressed("ui_up_p1"),
			"down_tap": _is_action_just_pressed_safe("ui_down_p1") or Input.is_action_just_pressed("ui_down"),
			"attack": Input.is_action_just_pressed("attack_p1")
		}
	else:
		return {
			"left": Input.is_action_pressed("ui_left_p2") or Input.is_action_pressed("ui_left"),
			"right": Input.is_action_pressed("ui_right_p2") or Input.is_action_pressed("ui_right"),
			"jump": Input.is_action_just_pressed("ui_up_p2") or Input.is_action_just_pressed("ui_up"),
			"jump_hold": Input.is_action_pressed("ui_up_p2") or Input.is_action_pressed("ui_up"),
			"down_tap": _is_action_just_pressed_safe("ui_down_p2") or Input.is_action_just_pressed("ui_down"),
			"attack": Input.is_action_just_pressed("attack_p2")
		}

func _is_action_just_pressed_safe(action_name: String) -> bool:
	return InputMap.has_action(action_name) and Input.is_action_just_pressed(action_name)

func _perform_double_jump(input_dir: int):
	velocity.y = double_jump_force
	jump_hold_timer = max_jump_hold_time * double_jump_hold_factor
	double_jump_control_timer = double_jump_control_time

	var jump_dir: int = input_dir
	if jump_dir == 0:
		jump_dir = int(signf(velocity.x))

	if jump_dir != 0:
		facing_dir = jump_dir
		var target_speed: float = float(jump_dir) * speed * double_jump_direction_speed_factor
		var turning_around := signf(velocity.x) != 0.0 and signf(velocity.x) != float(jump_dir)
		var burst_acceleration: float = double_jump_reverse_burst_acceleration if turning_around else double_jump_burst_acceleration
		velocity.x = move_toward(velocity.x, target_speed, burst_acceleration)

func perform_attack():
	is_attacking = true
	update_animation("attack")
	
	# Activate hitbox briefly
	if attack_hitbox:
		attack_hitbox.monitoring = true
	if attack_debug_fill:
		attack_debug_fill.show()
	if attack_debug_outline:
		attack_debug_outline.show()
	
	await get_tree().create_timer(0.3).timeout
	is_attacking = false
	if attack_hitbox:
		attack_hitbox.monitoring = false
	if attack_debug_fill:
		attack_debug_fill.hide()
	if attack_debug_outline:
		attack_debug_outline.hide()
	
	# Reset animation scale
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
		body.take_damage(attack_damage)
		print("Player %d hit Player %d for %.1f damage!" % [player_number, body.player_number, attack_damage])

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
