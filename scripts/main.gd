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
	# Center board
	$Board.position = get_viewport_rect().size * 0.5
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
	var over := Label.new()
	over.text = "Game Over\nClick to restart"
	over.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	over.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	over.size = get_viewport_rect().size
	over.add_theme_color_override("font_color", Color.from_string("#2D9CDB", Color.SKY_BLUE))
	$CanvasLayer/HUD.add_child(over)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if board.hearts <= 0 or board.moves_left <= 0:
			get_tree().reload_current_scene()
