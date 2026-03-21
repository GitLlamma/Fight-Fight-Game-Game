extends CharacterBody2D

class_name Player

@export var speed = 300.0
@export var jump_force = -400.0
@export var gravity = 800.0
@export var max_health = 100.0
@export var attack_damage = 10.0
@export var attack_cooldown = 0.5

var health: float
var current_velocity = Vector2.ZERO
var is_attacking = false
var attack_timer = 0.0
var player_number = 1
var facing_right = true

@onready var sprite = $Sprite
@onready var attack_hitbox = $AttackHitbox

var current_animation = "idle"
var animation_timer = 0.0

func _ready():
	health = max_health
	if attack_hitbox:
		attack_hitbox.area_entered.connect(_on_attack_hitbox_entered)
	if not sprite:
		sprite = $Sprite

func _physics_process(delta):
	var input = get_input()
	
	# Handle movement
	var moving = false
	if input["left"]:
		current_velocity.x = -speed
		moving = true
		if player_number == 1 and facing_right:
			facing_right = false
		elif player_number == 2 and not facing_right:
			facing_right = true
	elif input["right"]:
		current_velocity.x = speed
		moving = true
		if player_number == 1 and not facing_right:
			facing_right = true
		elif player_number == 2 and facing_right:
			facing_right = false
	else:
		current_velocity.x = 0
	
	# Update animation state
	if is_attacking:
		update_animation("attack")
	elif moving:
		update_animation("walk")
	else:
		update_animation("idle")
	
	# Handle jump
	if input["jump"] and is_on_floor():
		current_velocity.y = jump_force
		update_animation("jump")
	
	# Apply gravity
	current_velocity.y += gravity * delta
	
	# Handle attack
	if input["attack"] and attack_timer <= 0:
		perform_attack()
		attack_timer = attack_cooldown
	
	attack_timer -= delta
	
	# Flip sprite based on facing direction
	if sprite and player_number == 1:
		sprite.scale.x = 1.0 if facing_right else -1.0
	elif sprite and player_number == 2:
		sprite.scale.x = -1.0 if facing_right else 1.0
	
	velocity = current_velocity
	move_and_slide()

func get_input() -> Dictionary:
	if player_number == 1:
		return {
			"left": Input.is_action_pressed("ui_left"),
			"right": Input.is_action_pressed("ui_right"),
			"jump": Input.is_action_just_pressed("ui_up"),
			"attack": Input.is_action_just_pressed("attack_p1")
		}
	else:
		return {
			"left": Input.is_action_pressed("ui_left_p2"),
			"right": Input.is_action_pressed("ui_right_p2"),
			"jump": Input.is_action_just_pressed("ui_up_p2"),
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
	animation_timer = 0.0
	
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

func _on_attack_hitbox_entered(area):
	if area is Player and area != self:
		area.take_damage(attack_damage)

func take_damage(damage: float):
	health -= damage
	health = max(0, health)
	
	if health <= 0:
		die()

func die():
	print("Player %d defeated!" % player_number)
	# TODO: Emit signal to game manager
	queue_free()

func set_player_number(num: int):
	player_number = num
	if num == 1:
		facing_right = true
	else:
		facing_right = false
