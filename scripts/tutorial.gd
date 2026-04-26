extends Node2D
@onready var tutorial_pages = [$Pg1, $Pg2]
@onready var selected = 0
@onready var num_options = len(tutorial_pages)

func _ready() -> void:
	tutorial_pages[selected].visible = true

func _process(_delta: float) -> void:
	for player in range(4):
		if Input.is_action_just_pressed(Globals.character_input[player]['drop']):
			get_tree().change_scene_to_file("res://scenes/menu.tscn")
		
		if Input.is_action_just_pressed(Globals.character_input[player]["right"]) and selected != (len(tutorial_pages) - 1):
			var prev = selected
			selected = (selected + 1) % num_options
			tutorial_pages[prev].visible = false
			tutorial_pages[selected].visible = true
		elif Input.is_action_just_pressed(Globals.character_input[player]["left"]) and selected != 0:
			var prev = selected
			selected = posmod(selected - 1, num_options)
			tutorial_pages[prev].visible = false
			tutorial_pages[selected].visible = true
		elif Input.is_action_just_pressed(Globals.character_input[player]["dash"]) and selected == (len(tutorial_pages) - 1):
			get_tree().change_scene_to_file("res://scenes/character_select.tscn")
