extends Area2D
class_name Tile

signal clicked(tile: Tile)
signal scratched
signal explosion(v:Vector2)

const TYPE_CUPCAKE := 0
const TYPE_DONUT := 1
const TYPE_MACARON := 2
const TYPE_CAKE := 3
const TYPE_ICECREAM := 4
const TYPE_CAT := 5
const DESSERT_COUNT := 5

var type: int = 0
var anger: int = 0
var grid_pos: Vector2i
var base_scale := Vector2.ONE

@onready var sprite: Sprite2D = $Sprite2D

func set_grid_pos(p: Vector2i) -> void:
	grid_pos = p

func is_cat() -> bool:
	return type == TYPE_CAT

func set_type(t: int) -> void:
	type = t
	_refresh_texture()

func randomize_type(rng: RandomNumberGenerator, cat_chance := 0.07) -> void:
	if rng.randf() < cat_chance:
		set_type(TYPE_CAT)
	else:
		set_type(rng.randi_range(0, DESSERT_COUNT - 1))

func make_angry() -> void:
	if is_cat():
		anger = clamp(anger + 1, 0, 2)
		_refresh_texture()
		if anger >= 2:
			emit_signal("scratched")
			emit_signal("explosion", Vector2(-50, -50))
			calm_down()

func calm_down() -> void:
	anger = 0
	_refresh_texture()
	
func modulate_anger() -> void:
	var r = 1.0 + 0.3 * anger
	var g = 1.0 - 0.2 * anger
	var b = 1.0 - 0.2 * anger
	sprite.modulate = Color(r, g, b, 1.0)

func _refresh_texture() -> void:
	if is_cat():
		modulate_anger()
		match anger:
			0:
				sprite.texture = Sprites.cat_happy()
			1, 2:
				sprite.texture = Sprites.cat_angry()
	else:
		var idx := type # 0..4 desserts
		sprite.texture = Sprites.dessert_texture(idx)
	# fit to cell if set
	if sprite.texture:
		fit_to(Board.TILE_SIZE * 0.9)

func pop() -> void:
	var t := create_tween()
	t.tween_property(sprite, "scale", base_scale * 1.15, 0.12).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "modulate:a", 0.0, 0.22)

func fit_to(size: float) -> void:
	if sprite.texture:
		var tex_size := sprite.texture.get_size()
		var m: float = float(max(tex_size.x, tex_size.y))
		var f: float = size / m
		base_scale = Vector2(f, f)
		sprite.scale = base_scale

func set_selected(selected: bool) -> void:
	var target := base_scale * 1.06 if selected else base_scale
	create_tween().tween_property(sprite, "scale", target, 0.08)

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("clicked", self)
