extends Label

@onready var game_timer: Timer = $"../../GameTimer"
@onready var ms: Label = $ms

func _process(_delta: float) -> void:
	if game_timer.time_left:
		text = str(int(game_timer.time_left)).pad_zeros(2)
		ms.text = "." + str(int(fmod(game_timer.time_left, 1.0) * 100)).pad_zeros(2)
		
		if game_timer.time_left < 15:
			modulate = Color("#E25545").lerp(Color.WHITE, (game_timer.time_left - 10) / 5)
		if game_timer.time_left < 10:
			modulate = Color("#E25545")
	else:
		modulate = Color.WHITE
