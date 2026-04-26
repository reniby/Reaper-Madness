extends Node2D

@export var pickup_scene: PackedScene = preload("res://scenes/pickup.tscn")
@onready var player_scores: Array[Label] = [$Labels/P1, $Labels/P2, $Labels/P3, $Labels/P4]

var player_scene: PackedScene = preload("res://scenes/player.tscn")
var map_options_scene: PackedScene = preload("res://scenes/map_options.tscn")
var title = "Reaper Madness :D"
var player_positions = [
	Vector2(-120, -30),
	Vector2(-40,-30),
	Vector2(40, -30),
	Vector2(120, -30)
]

func _ready():
	var child = pickup_scene.instantiate()
	var map_options = map_options_scene.instantiate()
	var curr_map = map_options.get_children()[Globals.map_idx]
	curr_map.reparent(self)
	curr_map.get_child(0).visible = false
	
	# Add Speed-up Pickup
	#child.pickup_type = "Speed"
	#add_child(child)

	for i in range(Globals.numPlayers-1):
		child = pickup_scene.instantiate()
		child.pickup_type = "Coin"
		add_child(child)
	for i in range(len(Globals.players)):
		if Globals.players[i]:
			child = player_scene.instantiate()
			child.player = i
			add_child(child)
			child.global_position = player_positions[i]

func _process(_delta):
	DisplayServer.window_set_title(title + " | fps: " + str(Engine.get_frames_per_second()))
	for i in range(len(Globals.scores)):
		if Globals.players[i]:
			player_scores[i].text = str(Globals.scores[i])

func _on_game_timer_timeout() -> void:
	var winners = find_all_indices(Globals.scores, Globals.scores.max())

	if len(winners) == 1:
		Globals.winner = winners[0] + 1
	get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
	
func find_all_indices(array_to_search: Array, target_element) -> Array:
	var indices: Array = []
	for i in range(array_to_search.size()):
		if array_to_search[i] == target_element:
			indices.append(i)
	return indices
