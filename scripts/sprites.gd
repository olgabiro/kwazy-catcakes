extends Node
class_name Sprites

const ATLAS_PATH := "res://assets/sprites/sprites.png"
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

static func cat_happy() -> AtlasTexture:
	return make_region(0,0)

static func cat_grumpy1() -> AtlasTexture:
	return make_region(1,0)

static func cat_grumpy2() -> AtlasTexture:
	return make_region(2,0)

static func dessert_regions() -> Array[Rect2i]:
	return [
		rect(0,1), # burst/star
		rect(1,1), # cupcake
		rect(2,1), # donut
		rect(0,2), # macaron
		rect(1,2), # cake
		rect(2,2)  # ice cream
	]

static func dessert_texture(index:int) -> AtlasTexture:
	var t := AtlasTexture.new()
	t.atlas = atlas()
	t.region = dessert_regions()[index]
	return t

static func random_dessert_index(rng: RandomNumberGenerator) -> int:
	return rng.randi_range(0, dessert_regions().size() - 1)
