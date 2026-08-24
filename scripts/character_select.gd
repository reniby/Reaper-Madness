extends Node2D
@onready var labels: Array[Label] = [$Label]
@onready var press_play: Array[Label] = [$PressPlay1]
@onready var hold_play: Label = $HoldPlay
@onready var camera_2d: Camera2D = $Camera2D
@onready var player_anims: Array[AnimatedSprite2D] = [$PlayerAnim00]
@onready var ARROW_SCALE = player_anims[0].get_child(0).scale
@onready var dash_started = [0.0, 0.0, 0.0, 0.0]
@onready var dash_held = [0.0, 0.0, 0.0, 0.0]
@onready var held_min = 1000.0

var mode = 1 #0 for solo, 1 for versus
var rng = RandomNumberGenerator.new()
var shake_strength = 0.0
var randomStrength = 30.0
var holdRandomStrength = 12.0 / 1000.0
var shakeFade = 5.0
var temp_colors = [0, 1, 2, 3]
var taken_colors = [] # 0 - len(character_skin)
var num_colors = len(Globals.character_skin)
var held
var solo_player = 0

func apply_shake():
	shake_strength = randomStrength

var actions = ['left', 'right', 'up', 'down', 'dash', 'drop']

func _ready():
	Globals.resetCharselect()
	if Globals.gameMode == Globals.gameModeOptions.VERSUS:
		player_anims += [$PlayerAnim01, $PlayerAnim10, $PlayerAnim11]
		labels += [$Label2,$Label3,$Label4]
		press_play += [$PressPlay2, $PressPlay3, $PressPlay4]
	else:
		player_anims[solo_player].play()

func _process(delta: float) -> void:
	if Globals.gameMode == Globals.gameModeOptions.VERSUS:
		versus_process(delta)
	elif Globals.gameMode == Globals.gameModeOptions.SOLO:
		solo_process(delta)
	
	if shake_strength > 0 and not held:
		shake_strength = lerpf(shake_strength, 0, shakeFade * delta)
		camera_2d.offset = random_offset()
		
func random_offset():
	return Vector2(rng.randf_range(-shake_strength,shake_strength),rng.randf_range(-shake_strength,shake_strength))

func arrow_ui(player, locked_player):
	if Input.is_action_pressed(Globals.character_input[player]['left']):
		player_anims[locked_player].get_child(1).scale = ARROW_SCALE * 1.1
		player_anims[locked_player].get_child(1).modulate.a = 1

	elif Input.is_action_pressed(Globals.character_input[player]['right']):
		player_anims[locked_player].get_child(0).scale = ARROW_SCALE * 1.1
		player_anims[locked_player].get_child(0).modulate.a = 1

	elif Input.is_action_just_released(Globals.character_input[player]['left']) or Input.is_action_just_released(Globals.character_input[player]['right']):
		player_anims[locked_player].get_child(0).scale = ARROW_SCALE
		player_anims[locked_player].get_child(0).modulate.a = 0.8
		
		player_anims[locked_player].get_child(1).scale = ARROW_SCALE
		player_anims[locked_player].get_child(1).modulate.a = 0.8

func versus_process(_delta):
	for player in range(4):
		# Hold to Start
		if Input.is_action_pressed(Globals.character_input[player]["dash"]) and dash_started[player] == 0:
			dash_started[player] = Time.get_ticks_msec()
		elif Input.is_action_pressed(Globals.character_input[player]["dash"]):
			dash_held[player] = Time.get_ticks_msec() - dash_started[player]
		elif Input.is_action_just_released(Globals.character_input[player]["dash"]):
			dash_started[player] = 0.0
			dash_held[player] = 0.0
			hold_play.add_theme_color_override("font_color", Color(1,1,1))
			camera_2d.offset = Vector2(0,0)
			held = false

		var color_idx = temp_colors[player]
		# Joined Game, only versus
		if Input.is_action_just_pressed(Globals.character_input[player]["dash"]) and !Globals.players[player]:
			press_play[player].text = "P" + str(player + 1) + " joined!\nPress CONFIRM to select a Reaper"
			Globals.confirm.play()
			hold_play.add_theme_color_override("font_color", Color(1,1,1))
			camera_2d.offset = Vector2(0,0)
			held = false
			player_anims[player].visible = true
			player_anims[player].play()
			player_anims[player].play(Globals.character_skin[color_idx]['anim'])
			
			var tween = get_tree().create_tween()
			var player_tween = get_tree().create_tween()
			player_anims[player].scale = Vector2(10,10)
			press_play[player].add_theme_font_size_override("font_size", 150)
			tween.tween_property(press_play[player], "theme_override_font_sizes/font_size", 20, 0.5)
			player_tween.tween_property(player_anims[player], "scale", Vector2(3,3), 0.5)
			Globals.players[player] = true
			
			apply_shake()
			if Globals.players[player]:
				Globals.numPlayers += 1
		# Selected Color
		elif Input.is_action_just_pressed(Globals.character_input[player]["dash"]) and Globals.colors[player] == -1:
			press_play[player].text = "P" + str(player + 1) + " ready!\nPress BACK to leave"
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
			press_play[player].text = "P" + str(player + 1) + " joined!\nPress CONFIRM to select a Reaper"
			Globals.confirm.play()
			for child in player_anims[player].get_children(): 
					child.visible = true
			if temp_colors[player] in taken_colors:
				taken_colors.erase(temp_colors[player])
			Globals.colors[player] = -1

		# Return to Main Menu
		elif Input.is_action_just_pressed(Globals.character_input[player]['drop']) and Globals.players[player]:
			press_play[player].text = "Press CONFIRM\nto join"
			Globals.confirm.play()
			Globals.numPlayers -= 1
			player_anims[player].visible = false
			Globals.players[player] = false
		elif Input.is_action_just_pressed(Globals.character_input[player]['drop']) and Globals.numPlayers == 0:
			get_tree().change_scene_to_file("res://scenes/menu.tscn")

			if temp_colors[player] in taken_colors:
				taken_colors.erase(temp_colors[player])

		arrow_ui(player, player)

		# Scrool colors
		if Input.is_action_just_pressed(Globals.character_input[player]['left']) and temp_colors[player] not in taken_colors and Globals.players[player]:
			Globals.click.play()
			temp_colors[player] = posmod((temp_colors[player] - 1), num_colors)
			while (temp_colors[player] in taken_colors):
				temp_colors[player] =  posmod((temp_colors[player] - 1), num_colors)
			player_anims[player].self_modulate = Globals.character_skin[temp_colors[player]]['color']
			player_anims[player].play(Globals.character_skin[temp_colors[player]]['anim'])
		if Input.is_action_just_pressed(Globals.character_input[player]['right']) and temp_colors[player] not in taken_colors and Globals.players[player]:
			Globals.click.play()
			temp_colors[player] = (temp_colors[player] + 1) % num_colors
			while (temp_colors[player] in taken_colors):
				temp_colors[player] = posmod((temp_colors[player] + 1), num_colors)
			player_anims[player].self_modulate = Globals.character_skin[temp_colors[player]]['color']
			player_anims[player].play(Globals.character_skin[temp_colors[player]]['anim'])
		#if Globals.players[player]:
			#labels[player].text = "Player %d Joined\nPress 'O' to leave" % (player+1)
		#else:
			#labels[player].text = ""
	
	if Globals.numPlayers > Globals.gameMode:
		if (len(taken_colors) == Globals.numPlayers):
			hold_play.text = "Hold CONFIRM to start!"
			hold_play.add_theme_color_override("font_color", Color.WHITE.lerp(Color("16aa00ff"), (dash_held.max() / held_min)))
			start_game_shake()
		else:
			hold_play.text = ""
		if dash_held.max() >= held_min and (len(taken_colors) == Globals.numPlayers):
			Globals.colors = temp_colors
			get_tree().change_scene_to_file("res://scenes/map_select.tscn")

func solo_process(_delta):
	
	for player in range(4):
		# Hold to Start
		if Input.is_action_pressed(Globals.character_input[player]["dash"]) and dash_started[player] == 0:
			dash_started[player] = Time.get_ticks_msec()
		elif Input.is_action_pressed(Globals.character_input[player]["dash"]):
			dash_held[player] = Time.get_ticks_msec() - dash_started[player]
			hold_play.add_theme_color_override("font_color", Color(1,1,1))
			held = false
			camera_2d.offset = Vector2(0,0)
		elif Input.is_action_just_released(Globals.character_input[player]["dash"]):
			dash_started[player] = 0.0
			dash_held[player] = 0.0
			hold_play.add_theme_color_override("font_color", Color(1,1,1))
			camera_2d.offset = Vector2(0,0)
			held = false

		# Select Color
		if Input.is_action_just_pressed(Globals.character_input[player]["dash"]) and Globals.colors[solo_player] == -1:
			press_play[solo_player].text = "Hold CONFIRM to start!"
			apply_shake()
			Globals.confirm.play()
			taken_colors.append(temp_colors[solo_player])
			Globals.colors[solo_player] = temp_colors[solo_player]
			for child in player_anims[solo_player].get_children(): 
				child.visible = false
			player_anims[solo_player].self_modulate = Globals.character_skin[temp_colors[solo_player]]['color']
			player_anims[solo_player].play(Globals.character_skin[temp_colors[solo_player]]['anim'])

		# Deselect Color
		if Input.is_action_just_pressed(Globals.character_input[player]['drop']) and Globals.colors[solo_player] != -1:
			press_play[solo_player].text = "Press CONFIRM to select a Reaper"
			Globals.confirm.play()
			for child in player_anims[solo_player].get_children(): 
				child.visible = true
			if temp_colors[solo_player] in taken_colors:
				taken_colors.erase(temp_colors[solo_player])
			Globals.colors[solo_player] = -1

		# Return to Main Menu
		elif Input.is_action_just_pressed(Globals.character_input[player]['drop']) and Globals.colors[solo_player] == -1:
			get_tree().change_scene_to_file("res://scenes/menu.tscn")

		arrow_ui(player, solo_player)
		
		# Scroll colors
		if Input.is_action_just_pressed(Globals.character_input[player]['left']) and Globals.colors[solo_player] == -1:
			Globals.click.play()
			temp_colors[solo_player] = posmod((temp_colors[solo_player] - 1), num_colors)
			player_anims[solo_player].self_modulate = Globals.character_skin[temp_colors[solo_player]]['color']
			player_anims[solo_player].play(Globals.character_skin[temp_colors[solo_player]]['anim'])
		if Input.is_action_just_pressed(Globals.character_input[player]['right']) and Globals.colors[solo_player] == -1:
			Globals.click.play()
			temp_colors[solo_player] = (temp_colors[solo_player] + 1) % num_colors
			player_anims[solo_player].self_modulate = Globals.character_skin[temp_colors[solo_player]]['color']
			player_anims[solo_player].play(Globals.character_skin[temp_colors[solo_player]]['anim'])
	
	for i in range(1,4):
		temp_colors[i] = (temp_colors[solo_player] + i) % num_colors
	
	if Globals.colors[solo_player] != -1:
		#press_play[solo_player].text = "Press Confirm to select color!"
		#hold_play.text = "Press and hold X to start game!"
		start_game_shake()
		press_play[solo_player].add_theme_color_override("font_color", Color.WHITE.lerp(Color("1baa02ff"), (dash_held.max() / held_min)))
		
		if dash_held.max() >= held_min:
			Globals.colors = temp_colors
			get_tree().change_scene_to_file("res://scenes/map_select.tscn")
	else:
		press_play[solo_player].text = "Press CONFIRM to select a Reaper"
		hold_play.text = ""

func start_game_shake():
	held = true
	camera_2d.offset = Vector2(rng.randf_range(-dash_held.max() * holdRandomStrength / 2,dash_held.max() * holdRandomStrength / 2),rng.randf_range(-dash_held.max() * holdRandomStrength / 2,dash_held.max() * holdRandomStrength / 2))
