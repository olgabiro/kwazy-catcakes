extends Node2D

@onready var board: Board = $Board
@onready var score_label: Label = $CanvasLayer/HUD/Score
@onready var hearts_label: Label = $CanvasLayer/HUD/Hearts

func _ready() -> void:
	# Theme
	var theme_node := GameTheme.new()
	add_child(theme_node)
	theme_node.load_colors()
	var colors := theme_node.colors
	# Improve HUD contrast
	var font_col := Color.from_string(str(colors.get("highlight-white", "#F1F1F1")), Color(1,1,1))
	score_label.add_theme_color_override("font_color", font_col)
	var emoji_font = load("res://assets/fonts/NotoColorEmoji.ttf")
	hearts_label.add_theme_font_override("font", emoji_font)
	_layout_board()
	# Connect signals
	board.score_changed.connect(_on_score_changed)
	board.hearts_changed.connect(_on_hearts_changed)
	board.game_over.connect(_on_game_over)

func _on_score_changed(v:int) -> void:
	score_label.text = "Score: %d" % v

func _on_hearts_changed(v:int) -> void:
	hearts_label.text = "❤".repeat(max(v,0)) + "🖤".repeat(min(5-v,5))

func _on_game_over() -> void:
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
	label.text = "YOU DIED"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.from_string("#2D9CB", Color.FIREBRICK))
	label.add_theme_font_size_override("font_size", 70)

	var panel := ColorRect.new()
	panel.color = Color(0,0,0,0.9)
	panel.custom_minimum_size = Vector2(1920, 100)
	center.add_child(panel)
	label.position = Vector2(800, 0)
	panel.add_child(label)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if board.hearts <= 0:
			get_tree().reload_current_scene()

func _notification(what):
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_layout_board()

func _layout_board() -> void:
	var vp := get_viewport_rect().size
	var board_px := Vector2(Board.COLS * Board.TILE_SIZE, Board.ROWS * Board.TILE_SIZE)
	var top_margin := 100.0
	var x := vp.x * 0.5
	var y := top_margin + board_px.y * 0.5
	$Board.position = Vector2(x, y)

func _on_check_button_toggled(toggled_on: bool) -> void:
	var background_index = AudioServer.get_bus_index("Background")
	var sfx_index = AudioServer.get_bus_index("SFX")
	if !toggled_on:
		AudioServer.set_bus_mute(background_index, true)
		AudioServer.set_bus_mute(sfx_index, true)
	else:
		AudioServer.set_bus_mute(background_index, false)
		AudioServer.set_bus_mute(sfx_index, false)
