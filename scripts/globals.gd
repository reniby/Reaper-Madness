extends Node

var character_input = [{
	"up": "up_p1", 
	"down": "down_p1",
	"left": "left_p1",
	"right": "right_p1",
	"dash": "dash_p1",
	"drop": "tail_drop_p1"
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
	"up": "up_p3", 
	"down": "down_p3",
	"left": "left_p3",
	"right": "right_p3",
	"dash": "dash_p3",
	"drop": "tail_drop_p3"
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
	"color": "white",
	"anim": "john"
},
{
	"color": "#FF3F7F", #pink
	"anim": "ungabunga"
},
{
	"color": "#f2e605", #yellow
	"anim": "cyclops"
},
{
	"color": "#d387ff", #purple now orange now lilac
	"anim": "john"
},
{
	"color": "#4189e0", #sky blue
	"anim": "ungabunga"
},
{
	"color": "#43de5a", #forest green
	"anim": "cyclops"
}
]

func _ready():
	resetGlobals()

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

func resetGlobals():
	numPlayers = 0
	players = [false,false,false,false]
	winner = 0
	scores = [-1, -1, -1, -1]
	colors = [-1, -1, -1, -1]

	x_facing = 0
	y_facing = 0
	can_dash = true
	map_idx = 0
	
	superlative_actions = [actions_map.duplicate(),actions_map.duplicate(),actions_map.duplicate(),actions_map.duplicate()]
