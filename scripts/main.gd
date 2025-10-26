extends Node2D

@onready var board: Board = $Board
@onready var score_label: Label = $CanvasLayer/HUD/Score
@onready var hearts_label: Label = $CanvasLayer/HUD/Hearts
@onready var moves_label: Label = $CanvasLayer/HUD/Moves
@onready var bg: ColorRect = $BG
@onready var music: AudioStreamPlayer = $Music

func _ready() -> void:
	# Theme
	var theme_node := GameTheme.new()
	add_child(theme_node)
	theme_node.load_colors()
	var colors := theme_node.colors
	bg.color = Color.from_string(str(colors.get("shadow-purple", "#2B2255")), Color(0.12,0.1,0.2))
	# Improve HUD contrast
	var font_col := Color.from_string(str(colors.get("highlight-white", "#F1F1F1")), Color(1,1,1))
	score_label.add_theme_color_override("font_color", font_col)
	hearts_label.add_theme_color_override("font_color", font_col)
	moves_label.add_theme_color_override("font_color", font_col)
	# Layout board: top margin so bottom row isn't cropped
	_layout_board()
	# Connect signals
	board.score_changed.connect(_on_score_changed)
	board.hearts_changed.connect(_on_hearts_changed)
	board.moves_changed.connect(_on_moves_changed)
	board.game_over.connect(_on_game_over)
	# Loop background music
	if not music.finished.is_connected(func(): pass):
		music.finished.connect(func(): music.play())
	music.play()

func _on_score_changed(v:int) -> void:
	score_label.text = str(v)

func _on_hearts_changed(v:int) -> void:
	hearts_label.text = "❤".repeat(max(v,0))

func _on_moves_changed(v:int) -> void:
	moves_label.text = "Moves: %d" % v

func _on_game_over() -> void:
	music.stop()
	var overlay := Control.new()
	overlay.name = "GameOverOverlay"
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	# Make overlay clickable to restart
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			get_tree().reload_current_scene()
	)
	$CanvasLayer/HUD.add_child(overlay)
	var center := CenterContainer.new()
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	overlay.add_child(center)
	var label := Label.new()
	label.text = "Game Over\nClick to restart"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.from_string("#2D9CB", Color.FIREBRICK))
	# compute box size from text
	var pad := Vector2(100, 18)
	var box_size := label.get_minimum_size() + pad * 2.0
	var panel := ColorRect.new()
	panel.color = Color(0,0,0,0.9)
	panel.custom_minimum_size = box_size
	center.add_child(panel)
	label.position = pad
	label.size = box_size - pad * 2.0
	panel.add_child(label)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if board.hearts <= 0 or board.moves_left <= 0:
			get_tree().reload_current_scene()

func _notification(what):
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_layout_board()

func _layout_board() -> void:
	var vp := get_viewport_rect().size
	var board_px := Vector2(Board.COLS * Board.TILE_SIZE, Board.ROWS * Board.TILE_SIZE)
	var top_margin := 90.0
	var x := vp.x * 0.5
	var y := top_margin + board_px.y * 0.5
	$Board.position = Vector2(x, y)
