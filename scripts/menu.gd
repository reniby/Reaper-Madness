extends Node2D

@export var buttons: Array[Button] = []
@export var scenes: Array[String] = []
var button_dict = {}
var num_options: int

var selected = 0

func _ready():
	if has_node("FadeFromBlack"):
		var fade_from_black = $FadeFromBlack
		var tween = create_tween()
		tween.tween_property(fade_from_black, "color:a", 0, 0.6)
	num_options = len(buttons)
	buttons[selected].grab_focus()
	for i in num_options:
		button_dict[buttons[i]] = scenes[i]

func _process(_delta):
	for player in range(4):
		if Input.is_action_just_pressed(Globals.character_input[player]["up"]):
			var prev = selected
			selected = posmod(selected - 1, num_options)
			buttons[selected].grab_focus()
			for arrow in buttons[prev].get_children():
				arrow.visible = false
			for arrow in buttons[selected].get_children():
				arrow.visible = true
		elif Input.is_action_just_pressed(Globals.character_input[player]["down"]):
			var prev = selected
			selected = (selected + 1) % num_options
			buttons[selected].grab_focus()
			for arrow in buttons[prev].get_children():
				arrow.visible = false
			for arrow in buttons[selected].get_children():
				arrow.visible = true
		if Input.is_action_just_pressed(Globals.character_input[player]["dash"]):
			Globals.resetGlobals()
			get_tree().change_scene_to_file(button_dict[buttons[selected]])
			if has_node("FadeFromBlack"):
				var fade_from_black = $FadeFromBlack
				fade_from_black.color.a = 1
