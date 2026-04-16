extends Node2D
@onready var labels: Array[Label] = [$Label,$Label2,$Label3,$Label4]
@onready var press_play: Label = $PressPlay
@onready var camera_2d: Camera2D = $Camera2D
@onready var player_anims = [$PlayerAnim00, $PlayerAnim01, $PlayerAnim10, $PlayerAnim11]
var rng = RandomNumberGenerator.new()
var shake_strength = 0.0
var randomStrength = 30.0
var shakeFade = 5.0
var temp_colors = [0, 1, 2, 3]
var taken_colors = [] # 0 - len(character_skin)
var num_colors = len(Globals.character_skin)


func apply_shake():
	shake_strength = randomStrength
	

var actions = ['left', 'right', 'up', 'down', 'dash', 'drop']

func _process(delta: float) -> void:
	for player in range(4):
		var color_idx = temp_colors[player]
		if Input.is_action_just_pressed(Globals.character_input[player]["dash"]) and !Globals.players[player]:
			player_anims[player].visible = true
			player_anims[player].play()
			
			
			player_anims[player].modulate = Globals.character_skin[color_idx]['color']

			var tween = get_tree().create_tween()
			var player_tween = get_tree().create_tween()
			player_anims[player].scale = Vector2(10,10)
			labels[player].add_theme_font_size_override("font_size", 200)
			tween.tween_property(labels[player], "theme_override_font_sizes/font_size", 86, 0.5)
			player_tween.tween_property(player_anims[player], "scale", Vector2(3,3), 0.5)
			Globals.players[player] = true
			
			apply_shake()
			if Globals.players[player]:
				Globals.numPlayers += 1
		elif Input.is_action_just_pressed(Globals.character_input[player]["dash"]):
			taken_colors.append(temp_colors[player])
			Globals.colors[player] = temp_colors[player]
			for p in range(4):
				if Globals.colors[p] != -1: continue
				while (temp_colors[p] in taken_colors):
					temp_colors[p] = (temp_colors[p] + 1) % num_colors
				player_anims[p].modulate = Globals.character_skin[temp_colors[p]]['color']
			
		if Input.is_action_just_pressed(Globals.character_input[player]['drop']) and Globals.players[player]:
			Globals.numPlayers -= 1
			player_anims[player].visible = false
			Globals.players[player] = false
			
			if temp_colors[player] in taken_colors:
				taken_colors.erase(temp_colors[player])
			#if tween.is_running() and tween.is_valid():
				#tween.stop()
			#if player_tween.is_running() and player_tween.is_valid():
				#player_tween.stop()
			
					
		if Input.is_action_just_pressed(Globals.character_input[player]['left']) and temp_colors[player] not in taken_colors:
			temp_colors[player] = posmod((temp_colors[player] - 1), num_colors)
			while (temp_colors[player] in taken_colors):
				temp_colors[player] =  posmod((temp_colors[player] - 1), num_colors)
			player_anims[player].modulate = Globals.character_skin[temp_colors[player]]['color']
		if Input.is_action_just_pressed(Globals.character_input[player]['right']) and temp_colors[player] not in taken_colors:
			temp_colors[player] = (temp_colors[player] + 1) % num_colors
			while (temp_colors[player] in taken_colors):
				temp_colors[player] = posmod((temp_colors[player] + 1), num_colors)
			player_anims[player].modulate = Globals.character_skin[temp_colors[player]]['color']
		
		if Globals.players[player]:
			labels[player].text = "Player %d Joined\nPress again to leave" % (player+1)
		else:
			labels[player].text = ""

	if Globals.numPlayers > 1:
		press_play.text = "Press X to join!\nPress 'Start' to play!"
		if Input.is_action_just_pressed("start") and (len(taken_colors) == Globals.numPlayers):
			Globals.colors = temp_colors
			get_tree().change_scene_to_file("res://scenes/catfight.tscn")
	else:
		press_play.text = "Press X to join!"
		
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakeFade * delta)
		camera_2d.offset = randomOffset()
		
func randomOffset():
	return Vector2(rng.randf_range(-shake_strength,shake_strength),rng.randf_range(-shake_strength,shake_strength))
