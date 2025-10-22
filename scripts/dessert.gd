extends Area2D
class_name Dessert

signal collected(points:int)
signal missed

@export var fall_speed: float = 160.0
var _points := 10
var _velocity := Vector2.ZERO
var _screen_h := 0.0
var _rng := RandomNumberGenerator.new()
var _index := 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func setup(screen_h: float) -> void:
	_screen_h = screen_h
	_rng.randomize()
	_index = Sprites.random_dessert_index(_rng)
	sprite.texture = Sprites.dessert_texture(_index)
	_points = 10 + int(_index) * 5
	_velocity = Vector2(0, fall_speed)

func _process(delta: float) -> void:
	position += _velocity * delta
	if position.y - 32 > _screen_h:
		emit_signal("missed")
		queue_free()

func pop_collect_effect() -> void:
	var p := CPUParticles2D.new()
	p.amount = 40
	p.lifetime = 0.5
	p.one_shot = true
	p.emitting = true
	p.gravity = Vector2.ZERO
	p.scale_amount = 0.6
	p.initial_velocity_min = 60
	p.initial_velocity_max = 120
	p.texture = sprite.texture
	add_child(p)

func on_collected() -> void:
	pop_collect_effect()
	emit_signal("collected", _points)
	queue_free()
