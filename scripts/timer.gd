extends Label

@onready var game_timer: Timer = $"../../GameTimer"

func _process(_delta: float) -> void:
	if game_timer.time_left:
		text = str(int(game_timer.time_left) + 1) 
