extends Node
class_name Sprites

const ATLAS_PATH := "res://assets/sprites/sprites.png"
const DONUT_PATH := "res://assets/sprites/donut.png"
const COLS := 3
const ROWS := 3

static func atlas() -> Texture2D:
	return load(ATLAS_PATH)

static func tile_size() -> Vector2i:
	var a := atlas()
	var s := a.get_size()
	return Vector2i(int(s.x)/COLS, int(s.y)/ROWS)

static func rect(col:int, row:int) -> Rect2i:
	var T := tile_size()
	return Rect2i(col*T.x, row*T.y, T.x, T.y)

static func make_region(col:int, row:int) -> AtlasTexture:
	var t := AtlasTexture.new()
	t.atlas = atlas()
	t.region = rect(col,row)
	return t

static func cat_happy() -> Texture2D:
	return load("res://assets/sprites/kitten happy.png")
	
static func cat_angry() -> Texture2D:
	return load("res://assets/sprites/kitten angry.png")

static func kaboom() -> Texture2D:
	return load("res://assets/sprites/kaboom.png")
	
static func dessert_textures() -> Array[Texture2D]:
	return [
		load("res://assets/sprites/cupcake.png"),
		load("res://assets/sprites/donut.png"),
		load("res://assets/sprites/macaron.png"),
		load("res://assets/sprites/cake.png"),
		load("res://assets/sprites/ice cream.png")
	]

static func dessert_texture(index:int) -> AtlasTexture:
	return dessert_textures()[index]

static func random_dessert_index(rng: RandomNumberGenerator) -> int:
	return rng.randi_range(0, dessert_textures().size() - 1)
