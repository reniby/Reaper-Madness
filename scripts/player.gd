extends CharacterBody2D

const SPEED = 500.0
const JUMP_VELOCITY = -800.0

@export var player: Variant
@export var bot: bool
@onready var death_timer: Timer = $Timer/DeathTimer
@onready var i_timer: Timer = $Timer/ITimer
@onready var dash_timer: Timer = $Timer/DashTimer
@onready var speed_timer: Timer = $Timer/SpeedTimer
@onready var start_timer: Timer = $Timer/StartTimer
@onready var navigation: NavigationAgent2D = $NavigationAgent2D

@onready var camera = $"../Camera2D"
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
@onready var direction = Vector2(0,0)
@onready var coin_positions = []

const PLAYER_LAYER = 2
const COIN_LAYER = 3

const WALL_MASK = 1
const PLAYER_MASK = 2
const SPIKE_MASK = 3

const SPIKE_PHYSICS_LAYER = 12
const SPIKE_MOVING_PHSYICS_LAYER = 4

const X_BOUND = 600
const Y_BOUND = 300

var tail_obst: Line2D

var x_facing = 0
var y_facing = 0
var can_dash = true
var first_time = true
var bouncing = false
var starting_position

var bounce_timer = 0.0
const BOUNCE_TIME = 0.15

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var count = 0

func _ready():
	global_position = starting_position
	if bot:
		Globals.coin_change.connect(_on_coin_change)
	set_player_color(player)
	Globals.scores[player] = 0
	navigation.max_speed = SPEED
	find_closest_coin()

func _physics_process(delta):
	check_in_map()
	if start_timer.time_left:
		return

	# Bounce timer
	if bounce_timer > 0:
		bounce_timer -= delta

	if not bot:
		player_controller(delta)
	else:
		bot_controller(delta)
	var temp_vel = velocity
	move_and_slide()
	var last_collision = get_last_slide_collision()
	var alt_temp_vel = 50
	# Collide with player
	if last_collision != null and last_collision.get_collider() is CharacterBody2D:
		if bot: 
			bouncing = true
			bounce_timer = BOUNCE_TIME
		Globals.player_bonk.play(0.3)
		var collision = last_collision
		velocity = Vector2(cos(get_angle_to(collision.get_position()) - 3*PI/4), sin(get_angle_to(collision.get_position()) - 3*PI/4)).normalized() * [temp_vel.length(), alt_temp_vel].max() * 1.2
		hit_particles.global_position = collision.get_position()
		hit_particles.restart()
		Globals.superlative_actions[player]['num_bonks'] += 1
	# Collide with wall
	elif last_collision != null and (last_collision.get_collider() is TileMapLayer or last_collision.get_collider() is AnimatableBody2D):
		if bot:
			bouncing = true
			bounce_timer = BOUNCE_TIME
		var collision = last_collision
		var rid = collision.get_collider_rid()
		var layer = PhysicsServer2D.body_get_collision_layer(rid)
		
		if layer == SPIKE_PHYSICS_LAYER or layer == SPIKE_MOVING_PHSYICS_LAYER:
			death()
		else:
			Globals.wall_bonk.play(0.2)
			
		if last_collision.get_collider() is AnimatableBody2D:
			alt_temp_vel = last_collision.get_collider().get_parent().velocity.length() * 2
		velocity = Vector2(cos(get_angle_to(collision.get_position()) - PI), sin(get_angle_to(collision.get_position()) - PI)).normalized() * [temp_vel.length(), alt_temp_vel].max() * 1.2
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
	if Globals.gameMode == Globals.gameModeOptions.SOLO:
		direction = Vector2(0,0)
		for i in range(4):
			var temp_direction = Input.get_vector(Globals.character_input[i]["left"], Globals.character_input[i]["right"], Globals.character_input[i]["up"], Globals.character_input[i]["down"])
			if temp_direction != Vector2(0,0):
				direction = temp_direction
	else:
		direction = Input.get_vector(Globals.character_input[player]["left"], Globals.character_input[player]["right"], Globals.character_input[player]["up"], Globals.character_input[player]["down"])
	
	if direction and not death_timer.time_left:
		velocity = velocity.lerp(direction * curr_speed, 5*delta)
		Globals.superlative_actions[player]['dist_traveled'] += velocity.length() * delta
	else:
		velocity = velocity.lerp(Vector2(0,0), 5 * delta)
		
	var dashing = false
	if Globals.gameMode == Globals.gameModeOptions.SOLO:
		for i in range(4):
			if Input.is_action_just_pressed(Globals.character_input[i]["dash"]):
				dashing = true
	else:
		if Input.is_action_just_pressed(Globals.character_input[player]["dash"]):
			dashing = true
		
	if dashing and can_dash:
		Globals.dash.play()
		Globals.superlative_actions[player]['num_dashes'] += 1
		velocity = Vector2(cos(anim.rotation - PI/2), sin(anim.rotation - PI/2)).normalized() * curr_speed * 5 
		can_dash = false
		dash_timer.start()
		invincible = true
		var tween = get_tree().create_tween()
		tween.tween_property(anim, "modulate", Color.RED, 0.5)
		tween.tween_property(anim, "modulate", Color(Globals.character_skin[Globals.colors[player]]['color']), 0.5)
	if not death_timer.time_left:
		anim.rotation = lerp_angle(anim.rotation, atan2(velocity.x, -velocity.y), delta*10.0)
		shadow_anim.rotation = lerp_angle(shadow_anim.rotation, atan2(velocity.x, -velocity.y), delta*10.0)
		collision_shape.rotation = lerp_angle(anim.rotation, atan2(velocity.x, -velocity.y), delta*10.0)

# Trail layer 2 (on area entered = death)
# Wall layer 2
# Spike layer 3
func death():
	Globals.death.play()
	var death_particles = death_particles_scene.instantiate()
	get_parent().add_child(death_particles)
	death_particles.position = position
	death_particles.set_as_top_level(true)
	death_particles.particles.restart()
	death_particles.particles.color = Globals.character_skin[Globals.colors[player]]["color"]
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
	global_position = starting_position
	visible = true
	velocity = Vector2(0,0)
	anim.rotation = 0
	Globals.player_spawn.play(0.2)
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
	
func set_player_color(player_idx):
	var color_idx = Globals.colors[player_idx]
	anim.play(Globals.character_skin[color_idx]["anim"])
	shadow_anim.play(Globals.character_skin[color_idx]["anim"])
	trail.default_color = Globals.character_skin[color_idx]["color"]
	particles.color = Globals.character_skin[color_idx]['color']
	hit_particles.color = Globals.character_skin[color_idx]['color']
	anim.modulate = Globals.character_skin[color_idx]['color']

func bot_controller(_delta):
	if bounce_timer > 0:
		return

	# Bot Movement
	#var mouse_position = get_global_mouse_position()
	#navigation.target_position = mouse_position
	var curr_pos = global_position
	var next_pos = navigation.get_next_path_position()
	var new_vel = curr_pos.direction_to(next_pos) * SPEED
	
	if navigation.avoidance_enabled:
		navigation.set_velocity(new_vel)
	else:
		_on_bot_velocity_computed(new_vel)

func _on_bot_velocity_computed(safe_velocity: Vector2) -> void:
	if bot and bounce_timer <= 0:
		velocity = safe_velocity

func _on_coin_change():
	find_closest_coin()

func find_closest_coin():
	if Globals.coin_positions.is_empty():
		return

	var closest_coin = Globals.coin_positions[0]
	var closest_distance = global_position.distance_to(closest_coin.global_position)

	for coin in Globals.coin_positions:
		var distance = global_position.distance_to(coin.global_position)

		if distance < closest_distance:
			closest_coin = coin
			closest_distance = distance

	navigation.target_position = closest_coin.global_position

func check_in_map():
	if not death_timer.time_left and (
		abs(position.x) > abs(X_BOUND) or 
		abs(position.y) > abs(Y_BOUND)
	):
		death()
