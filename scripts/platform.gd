extends Node2D

@onready var animatable_body_2d: AnimatableBody2D = $AnimatableBody2D
@onready var tilemap: TileMapLayer = $AnimatableBody2D/TileMap
@onready var collision: CollisionShape2D = $AnimatableBody2D/Collision

@export var offset: Vector2 = Vector2(0, -320)
@export var duration: float = 5.0
@export var size_x: int = 4
@export var size_y: int = 2

func _ready():
	build_platform()
	update_collision()
	start_tween()

func build_platform():
	tilemap.clear()

	for x in range(size_x):
		for y in range(size_y):
			tilemap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))

func update_collision():
	var tile_size: Vector2 = Vector2(tilemap.tile_set.tile_size)
	var width = size_x * tile_size.x
	var height = size_y * tile_size.y

	collision.shape.size = Vector2(width, height)
	collision.position = Vector2(width / 2, height / 2)

func start_tween():
	var start_pos = animatable_body_2d.position
	var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	
	tween.tween_property(animatable_body_2d, "position", start_pos + offset, duration / 2.0)
	tween.tween_property(animatable_body_2d, "position", start_pos, duration / 2.0)
	tween.finished.connect(start_tween)
