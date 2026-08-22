extends CPUParticles2D
var rng = RandomNumberGenerator.new()
var max_y: int = 250 * 2
var max_x: int = 460 * 2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(rng.randf_range(0,0.3)).timeout
	var x = rng.randf_range(0, max_x)
	var y = rng.randf_range(0, max_y)
	position = Vector2(x, y)
	emitting = true

func _on_finished() -> void:
	await get_tree().create_timer(rng.randf_range(0.4,1.2)).timeout
	choose_firework_location()

func choose_firework_location():
	var x = rng.randf_range(0, max_x)
	var y = rng.randf_range(0, max_y)
	position = Vector2(x, y)
	restart()
