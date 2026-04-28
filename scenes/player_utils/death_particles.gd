extends Node2D
@onready var particles: CPUParticles2D = $particles



func _process(_delta: float) -> void:
	if not particles.emitting:
		queue_free()
		
