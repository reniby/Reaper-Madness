extends Label

@onready var labels: Array[Label] = [$"../1st", $"../2nd", $"../3rd", $"../4th"]
@onready var anims: Array[AnimatedSprite2D] = [$"../1st/Anim", $"../2nd/Anim", $"../3rd/Anim", $"../4th/Anim"]
@onready var scores: Array[Label] = [$"../1st/Score", $"../2nd/Score", $"../3rd/Score", $"../4th/Score"]
@onready var kds: Array[Label] = [$"../1st/KD", $"../2nd/KD", $"../3rd/KD", $"../4th/KD"]
@onready var timer_label: RichTextLabel = $"../Timer/Middle"
@onready var timer: Timer = $"../Timer/Timer"


@onready var fireworks: Node2D = $"../Fireworks"

var ranked = {}

func _ready():
	for s in len(Globals.scores):
		if Globals.scores[s] not in ranked:
			ranked[Globals.scores[s]] = []
		ranked[Globals.scores[s]].append(s)
	
	Globals.scores.sort()
	Globals.scores.reverse()
	Globals.winner = ranked[Globals.scores[0]][0]
	assign_firework_colors()
	for i in anims:
		i.visible = false
	for i in Globals.numPlayers:
		var currScore = Globals.scores[i]
		var currPlayer = ranked[Globals.scores[i]][0]
		ranked[Globals.scores[i]].pop_front() 
		
		labels[i].visible = true
		labels[i].text = "P" + str(currPlayer+1)
		scores[i].text = str(currScore)
		kds[i].text = str(Globals.superlative_actions[currPlayer]["num_kills"]) + str(":") + str(Globals.superlative_actions[currPlayer]["num_deaths"])
		
		var color = Color(Globals.character_skin[Globals.colors[currPlayer]]['color'])
		for child in labels[i].get_children():
			if child is not AnimatedSprite2D:
				child.modulate = color
		labels[i].self_modulate = color
		anims[i].play(Globals.character_skin[Globals.colors[currPlayer]]['anim'])
		anims[i].visible = true
		
	

func _process(_delta):
	timer_label.text = "Returning to main menu in " + "[color=64a569]" + str(int(timer.time_left)) + "[/color]" + " seconds..."


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
func assign_firework_colors():
	var fireworkArray = fireworks.get_children() 
	if len(ranked[Globals.scores[0]]) == 1:
		fireworks.modulate = Globals.character_skin[Globals.colors[Globals.winner]]['color']
	elif len(ranked[Globals.scores[0]]) == 2:
		for firework in fireworkArray:
			firework.color_initial_ramp.set_color(0,Globals.character_skin[Globals.colors[ranked[Globals.scores[0]][0]]]['color'])
			firework.color_initial_ramp.set_color(1,Globals.character_skin[Globals.colors[ranked[Globals.scores[0]][0]]]['color'])
			firework.color_initial_ramp.set_color(2,Globals.character_skin[Globals.colors[ranked[Globals.scores[0]][1]]]['color'])
			firework.color_initial_ramp.set_color(3,Globals.character_skin[Globals.colors[ranked[Globals.scores[0]][1]]]['color'])
	elif len(ranked[Globals.scores[0]]) == 4:
		for firework in fireworkArray:
			firework.color_initial_ramp.set_color(0,Globals.character_skin[Globals.colors[ranked[Globals.scores[0]][0]]]['color'])
			firework.color_initial_ramp.set_color(1,Globals.character_skin[Globals.colors[ranked[Globals.scores[0]][1]]]['color'])
			firework.color_initial_ramp.set_color(2,Globals.character_skin[Globals.colors[ranked[Globals.scores[0]][2]]]['color'])
			firework.color_initial_ramp.set_color(3,Globals.character_skin[Globals.colors[ranked[Globals.scores[0]][3]]]['color'])
	elif len(ranked[Globals.scores[0]]) == 3:
		var rng = RandomNumberGenerator.new()
		for firework in fireworkArray:
			firework.color_initial_ramp.set_color(0,Globals.character_skin[Globals.colors[ranked[Globals.scores[0]][0]]]['color'])
			firework.color_initial_ramp.set_color(1,Globals.character_skin[Globals.colors[ranked[Globals.scores[0]][1]]]['color'])
			firework.color_initial_ramp.set_color(2,Globals.character_skin[Globals.colors[ranked[Globals.scores[0]][2]]]['color'])
			firework.color_initial_ramp.set_color(3,Globals.character_skin[Globals.colors[ranked[Globals.scores[0]][rng.randi_range(0,2)]]]['color'])
	for firework in fireworkArray:
		firework.restart()
