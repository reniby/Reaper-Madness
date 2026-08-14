extends Node2D

@onready var body: AnimatableBody2D = $AnimatableBody2D
@onready var tilemap: TileMapLayer = $AnimatableBody2D/TileMap
#@onready var obstacle: NavigationObstacle2D = $NavigationObstacle2D

@export var offset: Vector2 = Vector2(0, -320)
@export var duration: float = 5.0
@export var size_x: int = 4
@export var size_y: int = 2
@export var n_spike: bool = false
@export var s_spike: bool = false
@export var e_spike: bool = false
@export var w_spike: bool = false

const PIXEL_WIDTH = 16
const PIXEL_HEIGHT = 16

var velocity: Vector2
var direction := 1
var start: Vector2

func _ready():
	build_platform()
	start = body.position
	#obstacle.radius = PIXEL_WIDTH / 2.0 * min(size_x, size_y)


func _physics_process(delta):
	var speed = offset / (duration / 2.0)
	velocity = speed * direction
	body.position += velocity * delta

	#obstacle.position = body.position + Vector2(size_x * PIXEL_WIDTH / 2.0, size_y * PIXEL_HEIGHT / 2.0)
	#obstacle.radius = 10

	if direction == 1 and body.position.distance_to(start + offset) < 1:
		direction = -1
	elif direction == -1 and body.position.distance_to(start) < 1:
		direction = 1


func build_platform():
	tilemap.clear()

	# Atlas Coords
	var horizontal = [0,1,3]
	var vertical = [0,1,2]
	for x in range(size_x):
		for y in range(size_y):
			var x_atlas = horizontal[1]
			if x == 0:
				x_atlas = horizontal[0]
			elif x == size_x - 1:
				x_atlas = horizontal[2]
			
			var y_atlas = vertical[1]
			if y == 0:
				y_atlas = vertical[0]
			elif y == size_y - 1:
				y_atlas = vertical[2]
			
			tilemap.set_cell(Vector2i(x, y), 2, Vector2i(x_atlas, y_atlas))
			
	
	for x in range(size_x):
		if n_spike:
			tilemap.set_cell(Vector2i(x, -1), 6, Vector2i(0, 0))
		if s_spike:
			tilemap.set_cell(Vector2i(x, size_y), 6, Vector2i(1, 0))
	for y in range(size_y):
		if w_spike:
			tilemap.set_cell(Vector2i(-1, y), 6, Vector2i(3, 0))
		if e_spike:
			tilemap.set_cell(Vector2i(size_x, y), 6, Vector2i(2, 0))
