extends Node

# PLAYER LABELS
# 1 = walls
# 2 = player to player
# 3 = coin
# 5 = also coin ??

# PLAYER MASKS
# 1 = walls
# 2 = player to player
# 3 = spikes

# COIN MASKS
# 4 = Respawn on wall
# 5 ??

# PL1 Moving
# L: 1 (player) 4 (coin respawn)
# M: 1 (player)

# PL1 Main
# L: 1 (player)
# M: 1 (player)

# PL2 Moving
# L: 3 --> 4 (Moving physics layer)
# M: 1 (player)

# PL2 Main
# L: 3 (??) 4 (coin respawn) --> 12 (Main physics layer)
# M: 1 (player)

var click = AudioStreamPlayer.new()
var confirm = AudioStreamPlayer.new()
var pickup = AudioStreamPlayer.new()
var death = AudioStreamPlayer.new()
var flame_spawn = AudioStreamPlayer.new()
var player_bonk = AudioStreamPlayer.new()
var wall_bonk = AudioStreamPlayer.new()
var dash = AudioStreamPlayer.new()
var ready_ = AudioStreamPlayer.new()
var set_ = AudioStreamPlayer.new()
var reap = AudioStreamPlayer.new()

enum gameModeOptions {SOLO, VERSUS}
var gameMode = gameModeOptions.VERSUS
var coin_positions = []
var coins_taken = []
signal coin_change()

var character_input = [{
	"up": "up_p1", 
	"down": "down_p1",
	"left": "left_p1",
	"right": "right_p1",
	"dash": "dash_p1",
	"drop": "tail_drop_p1"
},
{
	"up": "up_p3", 
	"down": "down_p3",
	"left": "left_p3",
	"right": "right_p3",
	"dash": "dash_p3",
	"drop": "tail_drop_p3"
},
{
	"up": "up_p2", 
	"down": "down_p2",
	"left": "left_p2",
	"right": "right_p2",
	"dash": "dash_p2",
	"drop": "tail_drop_p2"
},
{
	"up": "up_p4", 
	"down": "down_p4",
	"left": "left_p4",
	"right": "right_p4",
	"dash": "dash_p4",
	"drop": "tail_drop_p4"
}
]


var character_skin = [{
	"color": "#9BADB7",
	"anim": "john"
},
{
	"color": "#9B4639", #red
	"anim": "john-alt"
},
{
	"color": "#6EB0A4", #cyan
	"anim": "kraken"
},
{
	"color": "#6487CA", #blue
	"anim": "kraken-alt"
},
{
	"color": "#9E5B8D", #pink
	"anim": "unga"
},
{
	"color": "#9D5835", #orange
	"anim": "unga-alt"
},
{
	"color": "#A6A580", #green
	"anim": "cyclops"
},
{
	"color": "#715EBD", #purple
	"anim": "cyclops-alt"
}
]

var audio_player = AudioStreamPlayer.new()

var reset_timer
func _ready():
	resetGlobals()
	
	click.stream = preload("res://assets/sound_effects/menu_click.mp3")
	confirm.stream = preload("res://assets/sound_effects/character_join_confirm.mp3")
	pickup.stream = preload("res://assets/sound_effects/bell.wav")
	death.stream = preload("res://assets/sound_effects/death.mp3")
	player_bonk.stream = preload("res://assets/sound_effects/player_bonk.mp3")
	wall_bonk.stream = preload("res://assets/sound_effects/wall_bonk.mp3")
	dash.stream = preload("res://assets/sound_effects/dashing.mp3")
	
	ready_.stream = preload("res://assets/sound_effects/ready_set/3/3r.wav")
	set_.stream = preload("res://assets/sound_effects/ready_set/3/3s.wav")
	reap.stream = preload("res://assets/sound_effects/ready_set/3/3g.wav")

	click.volume_db = -15
	confirm.volume_db = -10
	pickup.volume_db = -20
	death.volume_db = -13
	player_bonk.volume_db = -20
	wall_bonk.volume_db = -25
	dash.volume_db = -20
	
	add_child(click)
	add_child(confirm)
	add_child(pickup)
	add_child(death)
	add_child(flame_spawn)
	add_child(player_bonk)
	add_child(wall_bonk)
	add_child(dash)
	add_child(ready_)
	add_child(set_)
	add_child(reap)
	
	reset_timer = Timer.new()
	add_child(reset_timer)
	reset_timer.wait_time = 180.0
	reset_timer.one_shot = false
	reset_timer.timeout.connect(_on_reset_timeout)
	reset_timer.start()

func _process(_delta):
	if Input.is_anything_pressed():
		reset_timer.start()

func _on_reset_timeout() -> void:
	resetGlobals()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

var numPlayers = 0
var players = [false,false,false,false]
var winner = 0
var scores = [-1, -1, -1, -1]
var colors = [-1, -1, -1, -1]

var x_facing = 0
var y_facing = 0
var can_dash = true
var map_idx = 0

var actions_map = 	{
		"num_dashes": 0, #done
		"num_kills": 0, 
		"num_deaths": 0, #done
		"num_bonks": 0, #done
		"tail_length_avg": 0,
		"dist_traveled": 0, #done
}
var superlative_actions = [actions_map.duplicate(),actions_map.duplicate(),actions_map.duplicate(),actions_map.duplicate()]

func resetCharselect():
	colors = [-1,-1,-1,-1]
	numPlayers = 0
	players = [false,false,false,false]

func resetGlobals():
	coin_positions = []
	winner = -1
	scores = [-1, -1, -1, -1]
	x_facing = 0
	y_facing = 0
	can_dash = true
	map_idx = 0
	superlative_actions = [actions_map.duplicate(),actions_map.duplicate(),actions_map.duplicate(),actions_map.duplicate()]
