extends Node2D
@onready var tutorial_pages = [$Pg1, $Pg2, $Pg3, $Pg4]
@onready var selected = 0
@onready var num_options = len(tutorial_pages)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tutorial_pages[selected].visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for player in range(4):
		if Input.is_action_just_pressed(Globals.character_input[player]['drop']):
			get_tree().change_scene_to_file("res://scenes/menu.tscn")
		if Input.is_action_just_pressed(Globals.character_input[player]["right"]):
			var prev = selected
			selected = (selected + 1) % num_options
			tutorial_pages[prev].visible = false
			tutorial_pages[selected].visible = true
			
		elif Input.is_action_just_pressed(Globals.character_input[player]["left"]):
			var prev = selected
			selected = posmod(selected - 1, num_options)
			tutorial_pages[prev].visible = false
			tutorial_pages[selected].visible = true
			
		elif Input.is_action_just_pressed(Globals.character_input[player]["dash"]) and selected == (len(tutorial_pages) - 1):
			get_tree().change_scene_to_file("res://scenes/character_select.tscn")
