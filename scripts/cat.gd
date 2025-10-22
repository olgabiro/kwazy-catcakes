extends Area2D
class_name Cat

signal grabbed(dessert: Dessert)

@export var move_speed: float = 600.0
@export var follow_mouse: bool = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	sprite.texture = Sprites.cat_happy()

func _unhandled_input(event: InputEvent) -> void:
	if follow_mouse and (event is InputEventMouse or event is InputEventScreenTouch or event is InputEventScreenDrag):
		var pos := get_viewport().get_mouse_position()
		position.x = pos.x

func move_to_x(x: float, delta: float) -> void:
	position.x = move_toward(position.x, x, move_speed * delta)

func celebrate() -> void:
	var t := create_tween()
	t.tween_property(sprite, "scale", Vector2(1.15, 0.9), 0.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(sprite, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
