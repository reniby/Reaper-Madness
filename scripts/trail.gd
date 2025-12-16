extends Line2D

@export var length = 20
@onready var area = $Area2D
@onready var shapes = []
var point = Vector2()
var prev = null
var active = true
var player
var max_length = 60
var starting_length = 20
@onready var tail_growth_timer: Timer = $TailGrow

func _ready():
	if get_parent() is CharacterBody2D:
		player = get_parent().player
	else:
		player = -1
	while get_point_count() > 0:
		remove_point(0)

func _physics_process(_delta):
	if get_parent().visible and get_parent() is CharacterBody2D:
		if get_parent().velocity != Vector2(0,0):
			global_position = Vector2(0,0)
			global_rotation = 0
			
			point = get_parent().global_position/get_parent().scale
			add_point(point)
			if len(points) > 0:
				var shape = CollisionShape2D.new()
				area.add_child(shape)
				var segment = SegmentShape2D.new()
				segment.a = points[points.size()-2]
				segment.b = points[points.size()-1]
				shape.shape = segment
				shapes.append(shape)
		elif get_point_count() > 0:
			shapes.pop_at(0).queue_free()
			remove_point(0)

		while get_point_count() >= length:
			shapes.pop_at(0).queue_free()
			remove_point(0)
	print(tail_growth_timer.time_left)
	print(length)
	if not tail_growth_timer.time_left and length <= max_length:
		length = length + 1
		tail_growth_timer.start()
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and player != body.player:
		body.death()
