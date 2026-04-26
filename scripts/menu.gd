extends Node2D
@onready var play: Button = $Play
@onready var tutorial: Button = $Tutorial
@onready var buttons: Array[Button] = [$Play, $Tutorial]
@onready var num_options: int = len(buttons)
@onready var scenes = {
	$Play: "res://scenes/character_select.tscn", 
	$Tutorial: "res://scenes/tutorial.tscn"
}
var selected = 0


func _ready():
	buttons[selected].grab_focus()
	
func _process(_delta):
	for player in range(4):
		if Input.is_action_just_pressed(Globals.character_input[player]["up"]):
			selected = posmod(selected - 1, num_options)
			buttons[selected].grab_focus()
		elif Input.is_action_just_pressed(Globals.character_input[player]["down"]):
			selected = (selected + 1) % num_options
			buttons[selected].grab_focus()
		elif Input.is_action_just_pressed(Globals.character_input[player]["dash"]):
			get_tree().change_scene_to_file(scenes[buttons[selected]])
