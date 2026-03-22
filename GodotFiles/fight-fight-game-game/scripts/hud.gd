extends CanvasLayer

@onready var p1_health_label = $VBoxContainer/P1HealthLabel
@onready var p2_health_label = $VBoxContainer/P2HealthLabel
@onready var win_screen = $WinScreen

func _ready():
	win_screen.hide()

func update_health(player_number: int, health: float, max_health: float):
	var health_percent = (health / max_health) * 100
	if player_number == 1:
		p1_health_label.text = "P1 Health: %.0f" % health_percent
	else:
		p2_health_label.text = "P2 Health: %.0f" % health_percent

func show_winner(player_number: int):
	win_screen.show()
	$WinScreen/WinLabel.text = "Player %d Wins!" % player_number
