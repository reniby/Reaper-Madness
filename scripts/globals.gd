extends Node

var numPlayers = 0
var players = [false,false,false,false]
var mode = 0
var winner = 0
var scores = [0, 0, 0, 0]
var colors = [-1, -1, -1, -1]

var x_facing = 0
var y_facing = 0
var can_dash = true

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


var character_skin = [#{
	#"color": "white",
	#"anim": "white_idle"
#},
#{
	#"color": "black",#17191b",
	#"anim": "indigo_idle"
#},
#{
	#"color": "#FF3F7F",
	#"anim": "pink_idle"
#},
{
	"color": "#FFC400",
	"anim": "red_idle"
},
{
	"color": "#450693",
	"anim": "indigo_idle"
},
{
	"color": "#4189e0", #sky blue
	"anim": "indigo_idle"
},
{
	"color": "#175420", #forest green
	"anim": "indigo_idle"
}
]

func resetGlobals():
	numPlayers = 0
	players = [false,false,false,false]
	mode = 0
	winner = 0
	scores = [0, 0, 0, 0]
