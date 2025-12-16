extends Node2D

var max_y: int = 250
var max_x: int = 460
var rng = RandomNumberGenerator.new()
var present = true


@onready var area: Area2D = $Area2D
@onready var particles: CPUParticles2D = $AmbientParticles

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var pickup_timer: Timer = $PickupTimer
@onready var pickup_behavior: Callable

@export_enum("Coin", "Speed") var pickup_type: String

func _ready() -> void:
	if pickup_type == "Coin":
		sprite.play("Ghost")
		pickup_timer.wait_time = 1
		pickup_behavior = Callable(self, "coin_behavior")
	elif pickup_type == "Speed":
		sprite.play("Coin")
		pickup_timer.wait_time = 5
		pickup_behavior = Callable(self, "speed_behavior")
	choose_location()

func _physics_process(_delta: float) -> void:
	var overlapping = false

	for body in area.get_overlapping_bodies():
		if body is CharacterBody2D:
			pickup_behavior.call(body)
			pickup_timer.start()

		sprite.visible = false
		area.set_collision_mask_value(3, false)
		
		particles.restart()
		particles.emitting = false
		particles.visible = false
		
		overlapping = true
		present = false
		choose_location()

	if not present and not overlapping and not pickup_timer.time_left:
		sprite.set_deferred("visible", true)
		particles.emitting = true
		particles.visible = true
		
		sprite.scale = Vector2(0,0)
		sprite.rotation = 0
		var tween = get_tree().create_tween()
		var duration = 0.3
		tween.tween_property(sprite, "rotation", 8*PI, duration)
		tween.set_parallel()
		tween.tween_property(sprite, "scale", Vector2(1,1), duration)
		
		await tween.finished
		present = true
		area.set_collision_mask_value(3, true)

func choose_location():
	var x = rng.randf_range(-max_x / 2, max_x / 2)
	var y = rng.randf_range(-max_y / 2, max_y / 2)
	position = Vector2(x, y)

func coin_behavior(playerBody):
	Globals.scores[playerBody.player] += 1

func speed_behavior(playerBody):
	playerBody.speed_timer.start()
	playerBody.curr_speed += 250
