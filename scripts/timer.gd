extends Label

@onready var game_timer: Timer = $"../../GameTimer"

func _ready():
	game_timer.start()

func _process(_delta: float) -> void:
	text = str(int(game_timer.time_left)) 
