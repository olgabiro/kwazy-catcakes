extends Node2D
class_name Board

signal score_changed(v:int)
signal hearts_changed(v:int)
signal moves_changed(v:int)
signal game_over

const COLS := 8
const ROWS := 8
const TILE_SIZE := 96.0
const MOVE_LIMIT := 30
const START_HEARTS := 5

var grid: Array = [] # 2D: [x][y] -> Tile
var selected: Tile
var rng := RandomNumberGenerator.new()
var score := 0
var hearts := START_HEARTS
var moves_left := MOVE_LIMIT
var is_dragging := false
var drag_start := Vector2.ZERO
var drag_threshold := 18.0

var tile_scene: PackedScene = null

func _ready() -> void:
	rng.randomize()
	tile_scene = load("res://scenes/Tile.tscn") as PackedScene
	_init_grid()
	_emit_all()

func _emit_all() -> void:
	emit_signal("score_changed", score)
	emit_signal("hearts_changed", hearts)
	emit_signal("moves_changed", moves_left)

func _init_grid() -> void:
	grid.resize(COLS)
	for x in range(COLS):
		grid[x] = []
		for y in range(ROWS):
			var t: Tile = tile_scene.instantiate()
			add_child(t)
			t.position = grid_to_pixel(Vector2i(x,y))
			t.set_grid_pos(Vector2i(x,y))
			t.randomize_type(rng)
			while _would_create_match_at(x,y,t.type):
				t.randomize_type(rng)
			t.clicked.connect(_on_tile_clicked)
			t.scratched.connect(_on_tile_scratched)
			grid[x].append(t)

func grid_to_pixel(g: Vector2i) -> Vector2:
	var origin := Vector2((COLS * TILE_SIZE) * -0.5 + TILE_SIZE*0.5, (ROWS * TILE_SIZE) * -0.5 + TILE_SIZE*0.5)
	return origin + Vector2(g.x * TILE_SIZE, g.y * TILE_SIZE)

func _on_tile_clicked(t: Tile) -> void:
	var mouse := get_viewport().get_mouse_position()
	if selected == null or t != selected:
		if selected:
			selected.set_selected(false)
		selected = t
		selected.set_selected(true)
		drag_start = mouse
		is_dragging = true
		return
	# second click on same tile cancels
	selected.set_selected(false)
	selected = null
	is_dragging = false

func _is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	return abs(a.x-b.x) + abs(a.y-b.y) == 1


func _perform_swap(a: Tile, b: Tile) -> void:
	# move count
	moves_left -= 1
	emit_signal("moves_changed", moves_left)
	# swap in grid
	var ga := a.grid_pos
	var gb := b.grid_pos
	grid[ga.x][ga.y] = b
	grid[gb.x][gb.y] = a
	a.set_grid_pos(gb)
	b.set_grid_pos(ga)
	_animate_move(a)
	_animate_move(b)
	# Cats get angry if moved
	if a.is_cat(): a.make_angry()
	if b.is_cat(): b.make_angry()
	# resolve
	await get_tree().process_frame
	var matched := _find_matches()
	if matched.size() == 0:
		# swap back
		grid[ga.x][ga.y] = a
		grid[gb.x][gb.y] = b
		a.set_grid_pos(ga)
		b.set_grid_pos(gb)
		_animate_move(a)
		_animate_move(b)
		return
	_clear_and_cascade(matched)
	if moves_left <= 0 or hearts <= 0:
		emit_signal("game_over")

func _animate_move(t: Tile) -> void:
	var target := grid_to_pixel(t.grid_pos)
	create_tween().tween_property(t, "position", target, 0.1)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_dragging and selected != null:
		var motion := event as InputEventMouseMotion
		var mouse: Vector2 = motion.position
		var delta: Vector2 = mouse - drag_start
		if delta.length() >= drag_threshold:
			var dir := Vector2i(0,0)
			if absf(delta.x) > absf(delta.y):
				dir = Vector2i(1,0) if delta.x > 0.0 else Vector2i(-1,0)
			else:
				dir = Vector2i(0,1) if delta.y > 0.0 else Vector2i(0,-1)
			var target := selected.grid_pos + dir
			if _in_bounds(target):
				var other: Tile = grid[target.x][target.y]
				if other:
					_perform_swap(selected, other)
			selected.set_selected(false)
			selected = null
			is_dragging = false
	elif event is InputEventMouseButton and not event.pressed:
		is_dragging = false

func _would_create_match_at(x:int, y:int, type:int) -> bool:
	# horizontal
	if x>=2 and grid[x-1][y] and grid[x-2][y] and grid[x-1][y].type==type and grid[x-2][y].type==type:
		return true
	# vertical
	if y>=2 and grid[x][y-1] and grid[x][y-2] and grid[x][y-1].type==type and grid[x][y-2].type==type:
		return true
	return false

func _find_matches() -> Array[Vector2i]:
	var to_clear: Array[Vector2i] = []
	# horizontal groups
	for y in range(ROWS):
		var run_type := -1
		var run_start := 0
		var run_len := 0
		for x in COLS:
			var t: Tile = grid[x][y] as Tile
			var tp := t.type
			if tp == run_type:
				run_len += 1
			else:
				if run_len >= 3:
					for rx in range(run_start, run_start+run_len):
						to_clear.append(Vector2i(rx, y))
				run_type = tp
				run_start = x
				run_len = 1
		# tail
		if run_len >= 3:
			for rx in range(run_start, run_start+run_len):
				to_clear.append(Vector2i(rx, y))
	# vertical groups
	for x in range(COLS):
		var run_type := -1
		var run_start := 0
		var run_len := 0
		for y in ROWS:
			var t: Tile = grid[x][y] as Tile
			var tp := t.type
			if tp == run_type:
				run_len += 1
			else:
				if run_len >= 3:
					for ry in range(run_start, run_start+run_len):
						to_clear.append(Vector2i(x, ry))
				run_type = tp
				run_start = y
				run_len = 1
		if run_len >= 3:
			for ry in range(run_start, run_start+run_len):
				to_clear.append(Vector2i(x, ry))
	return to_clear

func _clear_and_cascade(initial: Array[Vector2i]) -> void:
	var to_clear := initial.duplicate()
	# explosion if 3+ cats in a matched group
	var cat_count := 0
	for p in to_clear:
		if grid[p.x][p.y].is_cat():
			cat_count += 1
	if cat_count >= 3:
		hearts -= 1
		emit_signal("hearts_changed", hearts)
		# add neighbors around each cat
		for p in initial:
			if grid[p.x][p.y].is_cat():
				for nx in range(p.x-1, p.x+2):
					for ny in range(p.y-1, p.y+2):
						var q := Vector2i(nx,ny)
						if _in_bounds(q):
							to_clear.append(q)
	# unique
	to_clear = _unique_positions(to_clear)
	# pop and delete
	for p in to_clear:
		var t: Tile = grid[p.x][p.y]
		if t:
			t.pop()
			score += 10
			emit_signal("score_changed", score)
			t.queue_free()
			grid[p.x][p.y] = null
	# gravity and refill
	for x in range(COLS):
		var write_y := ROWS-1
		for y in range(ROWS-1, -1, -1):
			if grid[x][y] != null:
				if y != write_y:
					grid[x][write_y] = grid[x][y]
					grid[x][y] = null
					grid[x][write_y].set_grid_pos(Vector2i(x, write_y))
					_animate_move(grid[x][write_y])
				write_y -= 1
		for y in range(write_y, -1, -1):
			var t: Tile = tile_scene.instantiate()
			add_child(t)
			t.set_grid_pos(Vector2i(x, y))
			t.position = grid_to_pixel(Vector2i(x, -1))
			t.randomize_type(rng)
			grid[x][y] = t
			t.clicked.connect(_on_tile_clicked)
			t.scratched.connect(_on_tile_scratched)
			t.fit_to(TILE_SIZE * 0.9)
			_animate_move(t)
	await get_tree().create_timer(0.15).timeout
	var next := _find_matches()
	if next.size() > 0:
		_clear_and_cascade(next)

func _unique_positions(arr: Array[Vector2i]) -> Array[Vector2i]:
	var d := {}
	for p in arr:
		d[str(p)] = p
	var out: Array[Vector2i] = []
	for v in d.values():
		out.append(v as Vector2i)
	return out

func _in_bounds(p: Vector2i) -> bool:
	return p.x>=0 and p.y>=0 and p.x<COLS and p.y<ROWS

func _on_tile_scratched() -> void:
	hearts -= 1
	emit_signal("hearts_changed", hearts)
	if hearts <= 0:
		emit_signal("game_over")
