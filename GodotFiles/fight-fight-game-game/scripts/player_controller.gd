extends CharacterBody2D

class_name Player

signal health_changed(player_number: int, health: float, max_health: float)
signal defeated(player_number: int)

@export var speed = 300.0
@export var jump_force = -400.0
@export var gravity = 800.0
@export var max_health = 100.0
@export var attack_damage = 10.0
@export var attack_cooldown = 0.5

var health: float
var is_attacking = false
var attack_timer = 0.0
var player_number = 1
var facing_dir := 1

@onready var sprite = $Sprite
@onready var attack_hitbox = $AttackHitbox

var current_animation = "idle"

func _ready():
	health = max_health
	if attack_hitbox:
		attack_hitbox.body_entered.connect(_on_attack_hitbox_entered)
	if not sprite:
		sprite = $Sprite

func _physics_process(delta):
	var input = get_input()
	
	# Handle movement
	var moving = false
	if input["left"]:
		velocity.x = -speed
		moving = true
		facing_dir = -1
	elif input["right"]:
		velocity.x = speed
		moving = true
		facing_dir = 1
	else:
		velocity.x = 0
	
	# Update animation state
	if is_attacking:
		update_animation("attack")
	elif moving:
		update_animation("walk")
	else:
		update_animation("idle")
	
	# Handle jump
	if input["jump"] and is_on_floor():
		velocity.y = jump_force
		update_animation("jump")
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
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
			"attack": Input.is_action_just_pressed("attack_p1")
		}
	else:
		return {
			"left": Input.is_action_pressed("ui_left_p2") or Input.is_action_pressed("ui_left"),
			"right": Input.is_action_pressed("ui_right_p2") or Input.is_action_pressed("ui_right"),
			"jump": Input.is_action_just_pressed("ui_up_p2") or Input.is_action_just_pressed("ui_up"),
			"attack": Input.is_action_just_pressed("attack_p2")
		}

func perform_attack():
	is_attacking = true
	update_animation("attack")
	
	# Activate hitbox briefly
	if attack_hitbox:
		attack_hitbox.monitoring = true
	
	await get_tree().create_timer(0.3).timeout
	is_attacking = false
	if attack_hitbox:
		attack_hitbox.monitoring = false
	
	# Reset animation scale
	if sprite:
		sprite.scale.y = 1.0

func update_animation(anim_name: String):
	if current_animation == anim_name:
		return
	
	current_animation = anim_name
	
	# Visual feedback for animations
	if sprite:
		match anim_name:
			"idle":
				sprite.color = Color.WHITE
			"walk":
				sprite.color = Color(1.0, 1.0, 0.8)  # Slightly yellow tint
			"jump":
				sprite.color = Color(0.8, 1.0, 1.0)  # Slightly cyan tint
			"attack":
				sprite.color = Color(1.0, 0.6, 0.6)  # Slightly red tint
				sprite.scale.y = 1.1  # Slight scaling for visual feedback

func _on_attack_hitbox_entered(body):
	if body is Player and body != self:
		body.take_damage(attack_damage)
		print("Player %d hit Player %d for %.1f damage!" % [player_number, body.player_number, attack_damage])

func take_damage(damage: float):
	health -= damage
	health = max(0, health)
	health_changed.emit(player_number, health, max_health)
	
	if health <= 0:
		defeated.emit(player_number)
		die()

func die():
	print("Player %d defeated!" % player_number)
	queue_free()

func set_player_number(num: int):
	player_number = num
	if num == 1:
		facing_dir = 1
	else:
		facing_dir = -1
