extends Node2D
@onready var arrow_l: Sprite2D = $Arrow
@onready var arrow_r: Sprite2D = $Arrow2
@onready var ARROW_SCALE = arrow_l.scale


var map_options = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var map_options_scene: PackedScene = preload("res://scenes/map_options.tscn")
	var map_options_inst = map_options_scene.instantiate()
	add_child(map_options_inst)
	
	for map_option in map_options_inst.get_children():
		map_options.append(map_option)
	map_visibility()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var left_pressed = false
	var right_pressed = false
	for player in range(4):
		if Globals.players[player]:
			if Input.is_action_pressed(Globals.character_input[player]['left']):
				left_pressed = true
			if Input.is_action_pressed(Globals.character_input[player]['right']):
				right_pressed = true
				
			if Input.is_action_just_pressed(Globals.character_input[player]['left']):
				Globals.map_idx = posmod((Globals.map_idx - 1), len(map_options))
			if Input.is_action_just_pressed(Globals.character_input[player]['right']):
				Globals.map_idx = posmod((Globals.map_idx + 1), len(map_options))
			
			if Input.is_action_just_pressed(Globals.character_input[player]['dash']):
				get_tree().change_scene_to_file("res://scenes/catfight.tscn")
	
	map_visibility()
	arrow_ui(left_pressed, right_pressed)

func map_visibility():
	for i in range(len(map_options)):
		if i != Globals.map_idx:
			map_options[i].visible = false
		else:
			map_options[i].visible = true

func arrow_ui(left, right):
	arrow_l.scale = ARROW_SCALE
	arrow_r.scale = ARROW_SCALE
	if left:
		arrow_l.scale = ARROW_SCALE * 1.5
	if right:
		arrow_r.scale = ARROW_SCALE * 1.5
