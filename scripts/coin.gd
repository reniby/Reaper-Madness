extends Node2D

var max_y: int = 250
var max_x: int = 460
var rng = RandomNumberGenerator.new()

@onready var area: Area2D = $Area2D
@onready var particles: CPUParticles2D = $AmbientParticles

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var pickup_timer: Timer = $PickupTimer
@onready var pickup_behavior: Callable
@onready var point_light_2d: PointLight2D = $PointLight2D

@export_enum("Coin", "Speed") var pickup_type: String

func _ready() -> void:
	visible = false
	await get_tree().create_timer(3).timeout
	visible = true
	if pickup_type == "Coin":
		sprite.play("Ghost")
		pickup_timer.wait_time = 1
		pickup_behavior = Callable(self, "coin_behavior")
	elif pickup_type == "Speed":
		sprite.play("Coin")
		pickup_timer.wait_time = 5
		pickup_behavior = Callable(self, "speed_behavior")
	choose_location()

func _on_area_2d_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		Globals.pickup.play()
		pickup_behavior.call(body)
		pickup_timer.start()
		Globals.coin_change.emit()
		Globals.coin_positions.erase(self)
		hide_sprite()
	else:
		choose_location()

func _on_coin_timer_timeout() -> void:
	choose_location()

func show_sprite() -> void:
	sprite.visible = true
	point_light_2d.visible = true
	Globals.coin_change.emit()
	Globals.coin_positions.append(self)
	particles.emitting = true
	particles.visible = true
	sprite.scale = Vector2.ZERO
	sprite.rotation = 0.0
	Globals.flame_spawn.play()
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.3)
	tween.parallel()
	tween.tween_property(sprite, "rotation", 8.0 * PI, 0.3)
	await tween.finished
	area.set_collision_mask_value(3, true)

func hide_sprite():
	sprite.visible = false
	area.set_collision_mask_value(3, false)
	particles.restart()
	particles.emitting = false
	particles.visible = false
	point_light_2d.visible = false

func choose_location():
	var x = rng.randf_range(-max_x, max_x)
	var y = rng.randf_range(-max_y, max_y)
	position = Vector2(x, y)
	await get_tree().physics_frame
	await get_tree().process_frame

	for body in area.get_overlapping_bodies():
		if body is TileMapLayer:
			choose_location()
			return
	show_sprite()

func coin_behavior(playerBody):
	if playerBody.trail.length <= playerBody.trail.max_length:
		playerBody.trail.length += 10
	Globals.scores[playerBody.player] += 1

func speed_behavior(playerBody):
	playerBody.speed_timer.start()
	playerBody.curr_speed += 250
