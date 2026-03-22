extends Resource
class_name CharacterData

@export var character_id: StringName = &"default_fighter"
@export var display_name: String = "Default Fighter"
@export var weight: float = 1.0
@export var strength_multiplier: float = 1.0

# Core survivability
@export var max_health: float = 100.0

# Ground movement
@export var speed: float = 400.0
@export var ground_acceleration: float = 3000.0
@export var ground_deceleration: float = 2500.0

# Air movement
@export var air_acceleration: float = 850.0
@export var air_deceleration: float = 350.0
@export var air_release_deceleration: float = 700.0
@export var air_reverse_acceleration: float = 1100.0
@export var max_air_speed_factor: float = 0.92
@export var max_air_reverse_speed_factor: float = 0.72

# Jump/fall profile
@export var jump_force: float = -600.0
@export var max_jumps: int = 2
@export var double_jump_force: float = -560.0
@export var double_jump_hold_factor: float = 0.55
@export var double_jump_control_time: float = 0.25
@export var double_jump_air_acceleration: float = 1250.0
@export var double_jump_air_reverse_acceleration: float = 1450.0
@export var double_jump_direction_speed_factor: float = 0.9
@export var double_jump_burst_acceleration: float = 220.0
@export var double_jump_reverse_burst_acceleration: float = 360.0
@export var gravity: float = 2000.0
@export var max_fall_speed: float = 950.0
@export var fast_fall_speed: float = 1450.0
@export var fast_fall_gravity_multiplier: float = 1.5
@export var max_jump_hold_time: float = 0.13
@export var held_jump_gravity_multiplier: float = 0.31
@export var short_hop_velocity_multiplier: float = 0.62

# Combat
@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 0.5
@export var damage_flash_duration: float = 0.12

# Directional move slots (ground)
@export var ground_neutral_move: MoveData
@export var ground_up_move: MoveData
@export var ground_down_move: MoveData
@export var ground_forward_move: MoveData
@export var ground_back_move: MoveData

# Directional move slots (air)
@export var air_neutral_move: MoveData
@export var air_up_move: MoveData
@export var air_down_move: MoveData
@export var air_forward_move: MoveData
@export var air_back_move: MoveData
