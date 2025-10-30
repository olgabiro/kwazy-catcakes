extends Node
class_name Sprites

const COLS := 3
const ROWS := 3

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
