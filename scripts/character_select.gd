extends Node2D
@onready var labels: Array[Label] = [$Label,$Label2,$Label3,$Label4]
@onready var press_play: Label = $PressPlay
@onready var hold_play: Label = $HoldPlay
@onready var camera_2d: Camera2D = $Camera2D
@onready var player_anims: Array[AnimatedSprite2D] = [$PlayerAnim00, $PlayerAnim01, $PlayerAnim10, $PlayerAnim11]
@onready var ARROW_SCALE = player_anims[0].get_child(0).scale
@onready var dash_held = [0.0, 0.0, 0.0, 0.0]
@onready var held_min = 1.0

var rng = RandomNumberGenerator.new()
var shake_strength = 0.0
var randomStrength = 30.0
var shakeFade = 5.0
var temp_colors = [0, 1, 2, 3]
var taken_colors = [] # 0 - len(character_skin)
var num_colors = len(Globals.character_skin)
var held

func apply_shake():
	shake_strength = randomStrength

var actions = ['left', 'right', 'up', 'down', 'dash', 'drop']

func _process(delta: float) -> void:
	for player in range(4):
		if Input.is_action_pressed(Globals.character_input[player]["dash"]):
			dash_held[player] += delta
		elif Input.is_action_just_released(Globals.character_input[player]["dash"]):
			dash_held[player] = 0.0
			hold_play.add_theme_color_override("font_color", Color(1,1,1))

		var color_idx = temp_colors[player]
		# Joined Game
		if Input.is_action_just_pressed(Globals.character_input[player]["dash"]) and !Globals.players[player]:
			Globals.confirm.play()
			hold_play.add_theme_color_override("font_color", Color(1,1,1))
			player_anims[player].visible = true
			player_anims[player].play()
			player_anims[player].self_modulate = Globals.character_skin[color_idx]['color']
			player_anims[player].play(Globals.character_skin[color_idx]['anim'])
			
			var tween = get_tree().create_tween()
			var player_tween = get_tree().create_tween()
			player_anims[player].scale = Vector2(10,10)
			labels[player].add_theme_font_size_override("font_size", 150)
			tween.tween_property(labels[player], "theme_override_font_sizes/font_size", 70, 0.5)
			player_tween.tween_property(player_anims[player], "scale", Vector2(3,3), 0.5)
			Globals.players[player] = true
			
			apply_shake()
			if Globals.players[player]:
				Globals.numPlayers += 1
		# Selected Color
		elif Input.is_action_just_pressed(Globals.character_input[player]["dash"]) and Globals.colors[player] == -1:
			Globals.confirm.play()
			taken_colors.append(temp_colors[player])
			Globals.colors[player] = temp_colors[player]
			for child in player_anims[player].get_children(): 
					child.visible = false
			for p in range(4):
				if Globals.colors[p] != -1: continue
				while (temp_colors[p] in taken_colors):
					temp_colors[p] = (temp_colors[p] + 1) % num_colors
				player_anims[p].self_modulate = Globals.character_skin[temp_colors[p]]['color']
				player_anims[p].play(Globals.character_skin[temp_colors[p]]['anim'])
				
		# Deselect Color
		if Input.is_action_just_pressed(Globals.character_input[player]['drop']) and Globals.colors[player] != -1:
			Globals.confirm.play()
			for child in player_anims[player].get_children(): 
					child.visible = true
			if temp_colors[player] in taken_colors:
				taken_colors.erase(temp_colors[player])
			Globals.colors[player] = -1
		# Leave Game
		elif Input.is_action_just_pressed(Globals.character_input[player]['drop']) and Globals.players[player]:
			Globals.confirm.play()
			Globals.numPlayers -= 1
			player_anims[player].visible = false
			Globals.players[player] = false
		elif Input.is_action_just_pressed(Globals.character_input[player]['drop']) and Globals.numPlayers == 0:
			get_tree().change_scene_to_file("res://scenes/menu.tscn")

			if temp_colors[player] in taken_colors:
				taken_colors.erase(temp_colors[player])

		arrowUI(player)
		
		if Input.is_action_just_pressed(Globals.character_input[player]['left']) and temp_colors[player] not in taken_colors:
			Globals.click.play()
			temp_colors[player] = posmod((temp_colors[player] - 1), num_colors)
			while (temp_colors[player] in taken_colors):
				temp_colors[player] =  posmod((temp_colors[player] - 1), num_colors)
			player_anims[player].self_modulate = Globals.character_skin[temp_colors[player]]['color']
			player_anims[player].play(Globals.character_skin[temp_colors[player]]['anim'])
		if Input.is_action_just_pressed(Globals.character_input[player]['right']) and temp_colors[player] not in taken_colors:
			Globals.click.play()
			temp_colors[player] = (temp_colors[player] + 1) % num_colors
			while (temp_colors[player] in taken_colors):
				temp_colors[player] = posmod((temp_colors[player] + 1), num_colors)
			player_anims[player].self_modulate = Globals.character_skin[temp_colors[player]]['color']
			player_anims[player].play(Globals.character_skin[temp_colors[player]]['anim'])
		if Globals.players[player]:
			labels[player].text = "Player %d Joined\nPress 'O' to leave" % (player+1)
		else:
			labels[player].text = ""

	if Globals.numPlayers > 1:
		press_play.text = "Press X to join!"
		hold_play.text = "Press and hold X to start game once all players are ready!"
		if (len(taken_colors) == Globals.numPlayers):
			hold_play.add_theme_color_override("font_color", Color(1, 1-(dash_held.max()/held_min), 1-(dash_held.max()/held_min)))
		if dash_held.max() >= held_min and (len(taken_colors) == Globals.numPlayers):
			Globals.colors = temp_colors
			get_tree().change_scene_to_file("res://scenes/map_select.tscn")
	else:
		press_play.text = "Press X to join!"
		
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakeFade * delta)
		camera_2d.offset = randomOffset()
		
func randomOffset():
	return Vector2(rng.randf_range(-shake_strength,shake_strength),rng.randf_range(-shake_strength,shake_strength))

func arrowUI(player):
	if Input.is_action_pressed(Globals.character_input[player]['left']):
		player_anims[player].get_child(1).scale = ARROW_SCALE * 1.1
		player_anims[player].get_child(1).modulate.a = 1
	elif Input.is_action_pressed(Globals.character_input[player]['right']):
		player_anims[player].get_child(0).scale = ARROW_SCALE * 1.1
		player_anims[player].get_child(0).modulate.a = 1
	else:
		player_anims[player].get_child(0).scale = ARROW_SCALE
		player_anims[player].get_child(0).modulate.a = 0.8
		
		player_anims[player].get_child(1).scale = ARROW_SCALE
		player_anims[player].get_child(1).modulate.a = 0.8
