extends Node2D
@onready var labels: Array[Label] = [$Label,$Label2,$Label3,$Label4]
@onready var press_play: Label = $PressPlay
@onready var camera_2d: Camera2D = $Camera2D

var rng = RandomNumberGenerator.new()
var shake_strength = 0.0
var randomStrength = 30.0
var shakeFade = 5.0

func apply_shake():
	shake_strength = randomStrength
	
var character_input = [{
	"up": "up_p1", 
	"down": "down_p1",
	"left": "left_p1",
	"right": "right_p1",
	"dash": "dash_p1"
},
{
	"up": "up_p2", 
	"down": "down_p2",
	"left": "left_p2",
	"right": "right_p2",
	"dash": "dash_p2"
},
{
	"up": "up_p3", 
	"down": "down_p3",
	"left": "left_p3",
	"right": "right_p3",
	"dash": "dash_p3"
},
{
	"up": "up_p4", 
	"down": "down_p4",
	"left": "left_p4",
	"right": "right_p4",
	"dash": "dash_p4"
}
]
var actions = ['left', 'right', 'up', 'down', 'dash']

func _process(delta: float) -> void:
	for player in range(4):
		for action in actions:
			if Input.is_action_just_pressed(character_input[player][action]):
				var tween = get_tree().create_tween()
				labels[player].add_theme_font_size_override("font_size", 100)
				tween.tween_property(labels[player], "theme_override_font_sizes/font_size", 36, 0.5)
				Globals.players[player] = !Globals.players[player]
				apply_shake()
				if Globals.players[player]:
					Globals.numPlayers += 1
				else:
					Globals.numPlayers -= 1
					if tween.is_running() and tween.is_valid():
						tween.stop()
		
		if Globals.players[player]:
			labels[player].text = "Player %d Joined\nPress again to leave" % (player+1)
		else:
			labels[player].text = ""

	if Globals.numPlayers > 1:
		press_play.text = "Press X to join!\nPress 'Start' to play!"
		if Input.is_action_just_pressed("start"):
			get_tree().change_scene_to_file("res://scenes/catfight.tscn")
	else:
		press_play.text = "Press X to join!"
		
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakeFade * delta)
		camera_2d.offset = randomOffset()
		
func randomOffset():
	return Vector2(rng.randf_range(-shake_strength,shake_strength),rng.randf_range(-shake_strength,shake_strength))
