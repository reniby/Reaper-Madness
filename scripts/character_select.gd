extends Node2D
@onready var labels: Array[Label] = [$Label,$Label2,$Label3,$Label4]
@onready var press_play: Label = $PressPlay
@onready var camera_2d: Camera2D = $Camera2D
@onready var player_anim_00: AnimatedSprite2D = $PlayerAnim00
@onready var player_anim_01: AnimatedSprite2D = $PlayerAnim01
@onready var player_anim_10: AnimatedSprite2D = $PlayerAnim10
@onready var player_anim_11: AnimatedSprite2D = $PlayerAnim11
@onready var player_anims = [player_anim_00, player_anim_01, player_anim_10, player_anim_11]
var rng = RandomNumberGenerator.new()
var shake_strength = 0.0
var randomStrength = 30.0
var shakeFade = 5.0
var temp_colors = [0, 1, 2, 3]

func apply_shake():
	shake_strength = randomStrength
	

var actions = ['left', 'right', 'up', 'down', 'dash', 'drop']

func _process(delta: float) -> void:
	for player in range(4):
	
		if Input.is_action_just_pressed(Globals.character_input[player]["dash"]) and !Globals.players[player]:
			player_anims[player].visible = true
			player_anims[player].play()
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
				
		if Input.is_action_just_pressed(Globals.character_input[player]['drop']):
			if Globals.players[player]:
				Globals.numPlayers -= 1
				player_anims[player].visible = false
				Globals.players[player] = false
				#if tween.is_running() and tween.is_valid():
					#tween.stop()
				#if player_tween.is_running() and player_tween.is_valid():
					#player_tween.stop()
		
		if Globals.players[player]:
			print(Globals.players[player])
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
