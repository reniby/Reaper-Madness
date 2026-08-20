extends Node2D

func _process(_delta: float) -> void:
	for player in range(4):
		if Input.is_action_just_pressed(Globals.character_input[player]['drop']) or Input.is_action_just_pressed(Globals.character_input[player]['dash']):
			get_tree().change_scene_to_file("res://scenes/menu.tscn")
