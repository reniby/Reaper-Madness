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
	GlobalAudio.game_music.stop()
	GlobalAudio.menu_music.play()
	for s in len(Globals.scores):
		if Globals.scores[s] not in ranked:
			ranked[Globals.scores[s]] = []
		ranked[Globals.scores[s]].append(s)
	
	Globals.scores.sort()
	Globals.scores.reverse()
	Globals.winner = ranked[Globals.scores[0]][0]
	fireworks.modulate = Globals.character_skin[Globals.colors[Globals.winner]]['color']
	for i in anims:
		i.visible = false
	for i in Globals.numPlayers:
		var currScore = Globals.scores[i]
		var currPlayer = ranked[Globals.scores[i]][0]
		ranked[Globals.scores[i]].pop_front() 
		
		labels[i].visible = true
		labels[i].text = "P" + str(currPlayer+1)
		scores[i].text = str(currScore)
		kds[i].text = str(Globals.superlative_actions[i]["num_kills"]) + str(":") + str(Globals.superlative_actions[i]["num_deaths"])
		
		var color = Color(Globals.character_skin[Globals.colors[currPlayer]]['color'])
		labels[i].modulate = color

		anims[i].play(Globals.character_skin[Globals.colors[currPlayer]]['anim'])
		anims[i].visible = true
		
	

func _process(_delta):
	timer_label.text = "Returning to main menu in " + "[color=64a569]" + str(int(timer.time_left)) + "[/color]" + " seconds..."


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
