extends Label

@onready var p1: Label = $"../1st"
@onready var p2: Label = $"../2nd"
@onready var p3: Label = $"../3rd"
@onready var p4: Label = $"../4th"
@onready var a1: AnimatedSprite2D = $"../1st/Anim"
@onready var a2: AnimatedSprite2D = $"../2nd/Anim"
@onready var a3: AnimatedSprite2D = $"../3rd/Anim"
@onready var a4: AnimatedSprite2D = $"../4th/Anim"

var ranked = {}

func _ready():
	for s in len(Globals.scores):
		if Globals.scores[s] not in ranked:
			ranked[Globals.scores[s]] = []
		ranked[Globals.scores[s]].append(s)
	
	Globals.scores.sort()
	Globals.scores.reverse()
	
	var labels = [p1,p2,p3,p4]
	var anims = [a1,a2,a3,a4]
	for i in anims:
		i.visible = false
	for i in Globals.numPlayers:
		var currScore = Globals.scores[i]
		var currPlayer = ranked[Globals.scores[i]][0]
		ranked[Globals.scores[i]].pop_front() 
		
		labels[i].text = "Player " + str(currPlayer) + ": " + str(currScore)
		var color = Color(Globals.character_skin[Globals.colors[currPlayer]]['color'])
		labels[i].add_theme_color_override("font_color", color)
		anims[i].play(Globals.character_skin[Globals.colors[currPlayer]]['anim'])
		anims[i].self_modulate = Globals.character_skin[Globals.colors[currPlayer]]['color']
		anims[i].visible = true
		var new_anim = anims[i].duplicate()
		anims[i].get_parent().add_child(new_anim)
		new_anim.position.x = new_anim.position.x + 310
		new_anim.play()
	
