extends CharacterBody2D

const SPEED = 500.0
const JUMP_VELOCITY = -800.0

@export var player: int
@onready var death_timer: Timer = $Timer/DeathTimer
@onready var i_timer: Timer = $Timer/ITimer
@onready var dash_timer: Timer = $Timer/DashTimer
@onready var speed_timer: Timer = $Timer/SpeedTimer

@onready var camera = $"../Camera2D"
@onready var anim: AnimatedSprite2D = $Anim
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var hit_particles: CPUParticles2D = $HitParticles
@onready var shadow_anim: AnimatedSprite2D = $Shadow
@onready var tail_scene = preload("res://scenes/trail.tscn")
@onready var can_drop_tail = true
@onready var curr_speed: int = SPEED
@onready var invincible: bool = false
@onready var trail: Line2D = $Trail


var tail_obst: Line2D

var x_facing = 0
var y_facing = 0
var can_dash = true
var character_skin = [{
	"color": "white",
	"anim": "white_idle"
},
{
	"color": "black",#17191b",
	"anim": "blue_idle"
},
{
	"color": "#FF3F7F",
	"anim": "pink_idle"
},
{
	"color": "#FFC400",
	"anim": "red_idle"
},
{
	"color": "#450693",
	"anim": "indigo_idle"
}]
var character_input = [{
	"up": "up_p1", 
	"down": "down_p1",
	"left": "left_p1",
	"right": "right_p1",
	"dash": "dash_p1",
	"drop": "tail_drop_p1"
},
{
	"up": "up_p2", 
	"down": "down_p2",
	"left": "left_p2",
	"right": "right_p2",
	"dash": "dash_p2",
	"drop": "tail_drop_p2"
},
{
	"up": "up_p3", 
	"down": "down_p3",
	"left": "left_p3",
	"right": "right_p3",
	"dash": "dash_p3",
	"drop": "tail_drop_p3"
},
{
	"up": "up_p4", 
	"down": "down_p4",
	"left": "left_p4",
	"right": "right_p4",
	"dash": "dash_p4",
	"drop": "tail_drop_p4"
}
]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var count = 0

func _ready():

	anim.play(character_skin[player]["anim"])
	shadow_anim.play(character_skin[player]["anim"])
	trail.default_color = character_skin[player]["color"]
	particles.color = character_skin[player]['color']
	hit_particles.color = character_skin[player]['color']
	anim.modulate = character_skin[player]['color']
	if player == 0:
		anim.modulate = "white"

func _physics_process(delta):
	#var left = camera.get_viewport_rect().size.x/2 * -1
	#var right = camera.get_viewport_rect().size.x/2
	#var top = camera.get_viewport_rect().size.y/2 * -1
	#var bottom = camera.get_viewport_rect().size.y/2

	player_controller(delta)

	move_and_slide()
	if get_last_slide_collision() != null and get_last_slide_collision().get_collider() is CharacterBody2D:
		var collision = get_last_slide_collision()
		velocity = Vector2(cos(get_angle_to(collision.get_position()) - 3*PI/4), sin(get_angle_to(collision.get_position()) - 3*PI/4)).normalized() * curr_speed * 1.2
		hit_particles.global_position = collision.get_position()
		hit_particles.restart()
	particles.rotation = anim.rotation + PI/2
	if velocity.length() < 50:
		particles.emitting = false
	else:
		particles.emitting = true
			
	particles.initial_velocity_min = remap(velocity.length(),0, 1000,5,100)

	alt_tail_drop()


func player_controller(delta):
	var direction = Input.get_vector(character_input[player]["left"], character_input[player]["right"], character_input[player]["up"], character_input[player]["down"])
	if direction:
		velocity = velocity.lerp(direction * curr_speed, 5*delta)
	else:
		velocity = velocity.lerp(Vector2(0,0), 5 * delta)
	if Input.is_action_just_pressed(character_input[player]["dash"]) and can_dash:
		velocity = Vector2(cos(anim.rotation - PI/2), sin(anim.rotation - PI/2)).normalized() * curr_speed * 5 
		can_dash = false
		dash_timer.start()
		invincible = true
		var tween = get_tree().create_tween()
		tween.tween_property(anim, "modulate", Color.RED, 0.5)
		tween.tween_property(anim, "modulate", Color(character_skin[player]['color']), 0.5)
		
	anim.rotation = lerp_angle(anim.rotation, atan2(velocity.x, -velocity.y), delta*10.0)
	shadow_anim.rotation = lerp_angle(shadow_anim.rotation, atan2(velocity.x, -velocity.y), delta*10.0)
	collision_shape.rotation = lerp_angle(anim.rotation, atan2(velocity.x, -velocity.y), delta*10.0)

func death():
	visible = false
	
	particles.emitting = false
	particles.restart()
	set_collision_layer_value(2, false)
	set_collision_layer_value(3, false)
	death_timer.start()
	trail.clear_points()
	for coll in trail.shapes:
		coll.queue_free()
		trail.shapes = []

func _on_death_timer_timeout() -> void:
	position.x = 0
	position.y = 0
	visible = true
	trail.length = trail.starting_length
	i_timer.start()
	var tween = get_tree().create_tween()
	for i in range(4):
		tween.tween_property(anim, "modulate:a", 0.4, 0.25)
		tween.tween_property(anim, "modulate:a", 1, 0.25)
		
func _on_i_timer_timeout() -> void:
	set_collision_layer_value(2, true)
	set_collision_layer_value(3, true)

func _on_dash_timer_timeout() -> void:
	can_dash = true
	invincible = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and get_parent().player != body.player and not invincible:
		body.death()

func tail_drop():
	if Input.is_action_just_pressed(character_input[player]["drop"]) and can_drop_tail:
		can_drop_tail = false
		var tail_obst: Line2D = tail_scene.instantiate()
		tail_obst.texture = trail.texture
		tail_obst.width = trail.width
		tail_obst.texture_mode = trail.texture_mode
		tail_obst.default_color = trail.default_color
		get_parent().add_child(tail_obst)
		tail_obst.z_index = 100
		tail_obst.player = player
		var tail_obst_shapes = []
		for i in range(1,len(trail.points)):
			tail_obst.add_point(trail.points[i])
			var shape = CollisionShape2D.new()
			tail_obst.area.add_child(shape)
			var segment = SegmentShape2D.new()
			segment.a = trail.points[i-1]
			segment.b = trail.points[i]
			shape.shape = segment
			tail_obst_shapes.append(shape)
		
		await get_tree().create_timer(1.0).timeout
		
		while tail_obst.points.size() > 0 and is_instance_valid(tail_obst):
			tail_obst_shapes.pop_at(0).queue_free()
			tail_obst_shapes.pop_at(len(tail_obst.shapes)-1).queue_free()
			tail_obst.remove_point(0) 
			
			tail_obst.remove_point(len(tail_obst.points) - 1)
			await get_tree().create_timer(0.05).timeout 
		
		if is_instance_valid(tail_obst):
			can_drop_tail = true
			tail_obst.queue_free()
			
			
func alt_tail_drop():
	var highlight_color = 'orange'
	
	if Input.is_action_just_pressed(character_input[player]["drop"]) and can_drop_tail:
		can_drop_tail = false
		tail_obst = tail_scene.instantiate()
		tail_obst.texture = trail.texture
		tail_obst.width = trail.width
		tail_obst.texture_mode = trail.texture_mode
		tail_obst.default_color = highlight_color
		tail_obst.length = 1
		add_child(tail_obst)
		tail_obst.player = player
		
	if Input.is_action_pressed(character_input[player]["drop"]):
		if is_instance_valid(tail_obst) and tail_obst.length < trail.length:
			tail_obst.length += 0.3
	
	if Input.is_action_just_released(character_input[player]["drop"]) and is_instance_valid(tail_obst):
		trail.length = max(trail.length - tail_obst.length, trail.starting_length)
		tail_obst.z_index = 3
		tail_obst.reparent(get_parent())
		tail_obst.default_color = character_skin[player]["color"]
		await get_tree().create_timer(1.0).timeout
		
		while is_instance_valid(tail_obst) and tail_obst.points.size() > 1:
			tail_obst.remove_point(0) 
			tail_obst.shapes.pop_at(0).queue_free()
			tail_obst.remove_point(len(tail_obst.points) - 1)
			tail_obst.shapes.pop_at(len(tail_obst.shapes) - 1).queue_free()
			await get_tree().create_timer(0.05).timeout 
		
		if is_instance_valid(tail_obst):
			can_drop_tail = true
			tail_obst.queue_free()

func _on_speed_timer_timeout() -> void:
	curr_speed = SPEED
