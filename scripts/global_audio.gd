extends Node

@onready var menu_music: AudioStreamPlayer = $MenuMusic
@onready var game_music: AudioStreamPlayer = $GameMusic

func _ready():
	menu_music.volume_db = -10
