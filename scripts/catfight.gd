extends Node2D

@export var pickup_scene: PackedScene = preload("res://scenes/pickup.tscn")
@onready var player_scores: Array[Label] = [$Labels/P1/ScoreNode/PlayerScore, $Labels/P2/ScoreNode/PlayerScore, $Labels/P3/ScoreNode/PlayerScore, $Labels/P4/ScoreNode/PlayerScore]
@onready var game_timer: Timer = $GameTimer
@onready var fade2black: ColorRect = $CosmicBackgroundOuterSpace2
@onready var ready_to_slow: bool = false
@onready var player_ui: Array[Node2D] = [$Labels/P1,$Labels/P2,$Labels/P3,$Labels/P4]
@onready var kill_death_scores: Array[Label] = [$Labels/P1/KillDeathNode/KillDeathScore,$Labels/P2/KillDeathNode/KillDeathScore,$Labels/P3/KillDeathNode/KillDeathScore,$Labels/P4/KillDeathNode/KillDeathScore]
@onready var ready_set: Node2D = $ReadySet
@onready var ready_set_text: Label = $ReadySet/ReadySetText


var players = []
var post_timer: Timer
var player_scene: PackedScene = preload("res://scenes/player.tscn")
var map_options_scene: PackedScene = preload("res://scenes/map_options.tscn")
var title = "Reaper Madness :D"

const TWEEN_TIME = 3
const TWEEN_STEPS = 6.0
 
var player_positions = [
	Vector2(-475, -220),
	Vector2(-475, 220),
	Vector2(475, -220),
	Vector2(475, 220)
]


func _ready():

	ready_set.scale = Vector2(18,18)
	ready_set_text.modulate.a = 0.0
	var tween = get_tree().create_tween()
	#tween.set_parallel()
	
	tween.tween_property(ready_set, "scale", Vector2(1,1), TWEEN_TIME / TWEEN_STEPS).from_current().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(ready_set_text, "modulate:a", 1.0, TWEEN_TIME / TWEEN_STEPS)
	tween.tween_interval(TWEEN_TIME / TWEEN_STEPS)


	tween.tween_property(ready_set_text, "modulate:a", 0.0, 0.0)
	tween.tween_property(ready_set_text,"text", "Set!",0.0).from("Set!")
	tween.tween_property(ready_set, "scale", Vector2(1,1), TWEEN_TIME / TWEEN_STEPS).from(Vector2(18,18)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(ready_set_text, "modulate:a", 1.0, TWEEN_TIME / TWEEN_STEPS)
	
	tween.tween_interval(TWEEN_TIME / TWEEN_STEPS)
	tween.tween_property(ready_set_text, "modulate:a", 0.0, 0.0)
	tween.tween_property(ready_set_text,"text", "Reap!",0.0).from("Set!")
	tween.tween_property(ready_set, "scale", Vector2(1,1), TWEEN_TIME / TWEEN_STEPS).from(Vector2(18,18)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(ready_set_text, "modulate:a", 1.0, TWEEN_TIME / TWEEN_STEPS)
	tween.tween_interval(TWEEN_TIME / TWEEN_STEPS)
	
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
	var label = curr_map.get_tree().get_nodes_in_group("MapLabels")
	label[0].visible = false

	for i in range(len(player_scores)):
		var color = Color(Globals.character_skin[Globals.colors[i]]['color'])
		color.a = 0.5 
		player_ui[i].modulate = color #add_theme_color_override("font_color", color)
		player_ui[i].modulate.a = 1

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
			player_ui[i].visible = true
	
	if Globals.gameMode == Globals.gameModeOptions.SOLO:
		spawn_player()
		player_ui[0].visible = true
		for i in range(1,2):
			spawn_player(true, i)
			player_ui[i].visible = true

	await tween.finished
	ready_set.visible = false
	game_timer.start()
			

func _process(_delta):
	for i in range(len(Globals.scores)):
		if Globals.players[i] or (Globals.gameMode == Globals.gameModeOptions.SOLO):
			player_scores[i].text = str(Globals.scores[i]).pad_zeros(2)
			kill_death_scores[i].text = str(Globals.superlative_actions[i]["num_kills"]) + str(":") + str(Globals.superlative_actions[i]["num_deaths"])

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
	child.z_index = 5
	players.append(child)
	child.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(TWEEN_TIME).timeout
	child.process_mode = Node.PROCESS_MODE_INHERIT
	
