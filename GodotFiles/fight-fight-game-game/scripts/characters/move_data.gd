extends Resource
class_name MoveData

@export var move_id: StringName = &"neutral"
@export var display_name: String = "Neutral Attack"
@export var damage: float = 10.0
@export var cooldown: float = 0.5
@export var startup_frames: int = 4
@export var active_frames: int = 3
@export var endlag_frames: int = 12
