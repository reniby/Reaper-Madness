extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -800.0

@export var player: int
@onready var death_timer: Timer = $Timer/DeathTimer
@onready var i_timer: Timer = $Timer/ITimer
@onready var dash_timer: Timer = $Timer/DashTimer
@onready var speed_timer: Timer = $Timer/SpeedTimer
@onready var start_timer: Timer = $Timer/StartTimer

@onready var anim: AnimatedSprite2D = $Anim
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var hit_particles: CPUParticles2D = $HitParticles
@onready var shadow_anim: AnimatedSprite2D = $Shadow
@onready var tail_scene = preload("res://scenes/trail.tscn")
@onready var death_particles_scene = preload("res://scenes/player_utils/death_particles.tscn")
@onready var can_drop_tail = true
@onready var curr_speed = SPEED
@onready var invincible: bool = false
@onready var trail: Line2D = $Trail
@onready var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))

const PLAYER_LAYER = 2
const COIN_LAYER = 3

const WALL_MASK = 1
const PLAYER_MASK = 2
const SPIKE_MASK = 3

const SPIKE_PHYSICS_LAYER = 12
const SPIKE_MOVING_PHSYICS_LAYER = 4
var tail_obst: Line2D

var x_facing = 0
var y_facing = 0
var can_dash = true
var dir_timer: Timer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var count = 0

func _ready():
	dir_timer = Timer.new()
	add_child(dir_timer)
	dir_timer.wait_time = randf_range(0.3,0.6)
	dir_timer.one_shot = true
	dir_timer.start()
	set_player_color()

	

func _physics_process(delta):
	if start_timer.time_left:
		return
	player_controller(delta)

	move_and_slide()
	# Collide with player
	if get_last_slide_collision() != null and get_last_slide_collision().get_collider() is CharacterBody2D:
		var collision = get_last_slide_collision()
		velocity = Vector2(cos(get_angle_to(collision.get_position()) - 3*PI/4), sin(get_angle_to(collision.get_position()) - 3*PI/4)).normalized() * curr_speed * 1.2
		hit_particles.global_position = collision.get_position()
		hit_particles.restart()
		Globals.superlative_actions[player]['num_bonks'] += 1
	# Collide with wall
	elif get_last_slide_collision() != null and get_last_slide_collision().get_collider() is TileMapLayer:
		var collision = get_last_slide_collision()
		var rid = collision.get_collider_rid()
		var layer = PhysicsServer2D.body_get_collision_layer(rid)
		if layer == SPIKE_PHYSICS_LAYER or layer == SPIKE_MOVING_PHSYICS_LAYER:
			death()

		velocity = Vector2(cos(get_angle_to(collision.get_position()) - PI), sin(get_angle_to(collision.get_position()) - PI)).normalized() * SPEED * 1.2
		hit_particles.global_position = collision.get_position()
		hit_particles.restart()
		Globals.superlative_actions[player]['num_bonks'] += 1
	particles.rotation = anim.rotation + PI/2
	if velocity.length() < 50:
		particles.emitting = false
	else:
		particles.emitting = true
			
	particles.initial_velocity_min = remap(velocity.length(),0, 1000,5,100)

	#alt_tail_drop()
	if trail.length > trail.starting_length:
		trail.length = trail.length - (2 * delta)


func player_controller(delta):
	
	if not dir_timer.time_left:
		direction = Vector2(rand_dir(), rand_dir()) #Input.get_vector(Globals.character_input[player]["left"], Globals.character_input[player]["right"], Globals.character_input[player]["up"], Globals.character_input[player]["down"])
		dir_timer.wait_time = randf_range(0.3,0.6)
		dir_timer.start()
	if direction:
		velocity = velocity.lerp(direction * curr_speed, 5*delta)
		Globals.superlative_actions[player]['dist_traveled'] += velocity.length() * delta
	else:
		velocity = velocity.lerp(Vector2(0,0), 5 * delta)
	#if Input.is_action_just_pressed(Globals.character_input[player]["dash"]) and can_dash:
		#Globals.superlative_actions[player]['num_dashes'] += 1
		#velocity = Vector2(cos(anim.rotation - PI/2), sin(anim.rotation - PI/2)).normalized() * curr_speed * 5 
		#can_dash = false
		#dash_timer.start()
		#invincible = true
		#var tween = get_tree().create_tween()
		#tween.tween_property(anim, "modulate", Color.RED, 0.5)
		#tween.tween_property(anim, "modulate", Color(Globals.character_skin[Globals.colors[player]]['color']), 0.5)
		#
	anim.rotation = lerp_angle(anim.rotation, atan2(velocity.x, -velocity.y), delta*10.0)
	shadow_anim.rotation = lerp_angle(shadow_anim.rotation, atan2(velocity.x, -velocity.y), delta*10.0)
	collision_shape.rotation = lerp_angle(anim.rotation, atan2(velocity.x, -velocity.y), delta*10.0)

# Trail layer 2 (on area entered = death)
# Wall layer 2
# Spike layer 3
func death():
	var death_particles = death_particles_scene.instantiate()
	get_parent().add_child(death_particles)
	death_particles.position = position
	death_particles.set_as_top_level(true)
	death_particles.particles.restart()
	death_particles.particles.color = Globals.character_skin[player + 1]["color"]
	Globals.superlative_actions[player]['num_deaths'] += 1
	visible = false
	
	particles.emitting = false
	particles.restart()
	# Disable all
	set_collision_layer_value(PLAYER_LAYER, false)
	set_collision_layer_value(COIN_LAYER, false)
	set_collision_mask_value(WALL_MASK, false)
	set_collision_mask_value(PLAYER_MASK, false)
	set_collision_mask_value(SPIKE_MASK, false)
	death_timer.start()
	trail.clear_points()
	for coll in trail.shapes:
		coll.queue_free()
		trail.shapes = []

func _on_death_timer_timeout() -> void:
	position.x = 500 + randf_range(-50,50)
	position.y = 300 + randf_range(-50,50)
	visible = true
	# Re enable wall and coin
	set_collision_layer_value(COIN_LAYER, true)
	set_collision_mask_value(WALL_MASK, true)

	trail.length = trail.starting_length
	i_timer.start()
	var tween = get_tree().create_tween()
	for i in range(4):
		tween.tween_property(anim, "modulate:a", 0.4, 0.25)
		tween.tween_property(anim, "modulate:a", 1, 0.25)
		
func _on_i_timer_timeout() -> void:
	pass
	# Re enable spike, player
	set_collision_layer_value(PLAYER_LAYER, true)
	set_collision_mask_value(PLAYER_MASK, true)
	set_collision_mask_value(SPIKE_MASK, true)

func _on_dash_timer_timeout() -> void:
	can_dash = true
	invincible = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and get_parent().player != body.player and not invincible:
		body.death()

func _on_speed_timer_timeout() -> void:
	curr_speed = SPEED
	
func set_player_color():
	var color_idx = player + 1
	anim.play(Globals.character_skin[color_idx]["anim"])
	shadow_anim.play(Globals.character_skin[color_idx]["anim"])
	trail.default_color = Globals.character_skin[color_idx]["color"]
	particles.color = Globals.character_skin[color_idx]['color']
	hit_particles.color = Globals.character_skin[color_idx]['color']
	anim.modulate = Globals.character_skin[color_idx]['color']
	
func rand_dir():
	var ranges = [Vector2(-1.0, -0.5), Vector2(0.5, 1.0)]
	var selected_range = ranges.pick_random() # GDScript 4.x feature
	var result = randf_range(selected_range.x, selected_range.y)
	
	return result
