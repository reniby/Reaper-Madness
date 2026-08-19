extends Node2D

@export var pickup_scene: PackedScene = preload("res://scenes/pickup.tscn")
@onready var player_scores: Array[Label] = [$Labels/P1, $Labels/P2, $Labels/P3, $Labels/P4]
@onready var game_timer: Timer = $GameTimer
@onready var fade2black: ColorRect = $CosmicBackgroundOuterSpace2
@onready var ready_to_slow: bool = false

var players = []
var post_timer: Timer
var player_scene: PackedScene = preload("res://scenes/player.tscn")
var map_options_scene: PackedScene = preload("res://scenes/map_options.tscn")
var title = "Reaper Madness :D"
 
var player_positions = [
	Vector2(-120, -30),
	Vector2(-40, -30),
	Vector2(40, -30),
	Vector2(120, -30)
]

func _ready():
	post_timer = Timer.new()
	post_timer.one_shot = true
	post_timer.wait_time = 1.0
	post_timer.ignore_time_scale = true 
	add_child(post_timer)
	post_timer.timeout.connect(_on_post_timer_timeout)

	var child = pickup_scene.instantiate()
	var map_options = map_options_scene.instantiate()
	var curr_map = map_options.get_children()[Globals.map_idx]
	curr_map.reparent(self)
	curr_map.visible = true
	curr_map.get_child(0).visible = false

	for i in range(len(player_scores)):
		var color = Color(Globals.character_skin[Globals.colors[i]]['color'])
		color.a = 0.5 
		player_scores[i].add_theme_color_override("font_color", color)

	# Add Speed-up Pickup
	#child.pickup_type = "Speed"
	#add_child(child)
	if Globals.gameMode == Globals.gameModeOptions.SOLO:
		Globals.numPlayers = 4
		
	for i in range(Globals.numPlayers-1):
		child = pickup_scene.instantiate()
		child.pickup_type = "Coin"
		add_child(child)

	for i in range(len(Globals.players)):
		if Globals.players[i]:
			spawn_player(false, i)
	
	if Globals.gameMode == Globals.gameModeOptions.SOLO:
		spawn_player()
		for i in range(1,4):
			spawn_player(true, i)
			
				

func _process(_delta):
	DisplayServer.window_set_title(title + " | fps: " + str(Engine.get_frames_per_second()))
	for i in range(len(Globals.scores)):
		if Globals.players[i] or (Globals.gameMode == Globals.gameModeOptions.SOLO):
			player_scores[i].text = str(Globals.scores[i])

func _on_game_timer_timeout() -> void:
	if ready_to_slow:
		return

	ready_to_slow = true

	for _player in players:
		_player.death()

	var tween = create_tween()
	tween.tween_property(Engine, "time_scale", 0.1, 0.3)
	tween.parallel()
	tween.tween_property(fade2black, "color:a", 1, 0.3)

	post_timer.start()

func _on_post_timer_timeout() -> void:
	Engine.time_scale = 1
	fade2black.color.a = 0.0
	get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
	
func spawn_player(bot = false, player = 0):
	var child = player_scene.instantiate()
	child.bot = bot
	child.player = player
	child.starting_position = player_positions[player]
	add_child(child)
	players.append(child)
