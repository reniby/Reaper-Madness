extends Node

@onready var menu_music: AudioStreamPlayer = $MenuMusic

@onready var game_music_options: Array[AudioStreamPlayer] = [$GameMusic1,$GameMusic3,$GameMusic4]

func _ready():
	menu_music.volume_db = -10
	
func play_random_game_music():
	var game_music = game_music_options.pick_random()
	game_music.play()
