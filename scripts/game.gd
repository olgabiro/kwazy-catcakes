extends Node2D

@onready var cat: Cat = $Cat
@onready var spawn_timer: Timer = $SpawnTimer
@onready var score_label: Label = $CanvasLayer/HUD/Score
@onready var lives_label: Label = $CanvasLayer/HUD/Lives
@onready var bg: ColorRect = $CanvasLayer/BG
@onready var music: AudioStreamPlayer = $Music

var score := 0
var lives := 3
var speed_scale := 1.0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	# Theme
	var theme_node := GameTheme.new()
	add_child(theme_node)
	var colors := theme_node.colors
	var bg_color := Color.from_string(str(colors.get("highlight-white", "#F1F1F1")), Color(0.945,0.945,0.945))
	bg.color = bg_color
	# Setup
	update_hud()
	spawn_timer.start()
	music.play()

func update_hud() -> void:
	score_label.text = str(score)
	lives_label.text = "❤".repeat(lives)

func _on_SpawnTimer_timeout() -> void:
	spawn_dessert()
	# Increase difficulty
	speed_scale = clamp(speed_scale + 0.02, 1.0, 2.2)
	spawn_timer.wait_time = max(0.4, spawn_timer.wait_time * 0.98)

func spawn_dessert() -> void:
	var d: Dessert = load("res://scenes/Dessert.tscn").instantiate()
	var viewport := get_viewport_rect()
	var x := rng.randf_range(40.0, viewport.size.x - 40.0)
	d.position = Vector2(x, -30)
	d.fall_speed *= speed_scale
	add_child(d)
	d.setup(viewport.size.y)
	d.collected.connect(_on_dessert_collected)
	d.missed.connect(_on_dessert_missed)
	# Connect overlap with cat for collection
	d.area_entered.connect(func(a):
		if a == cat:
			cat.celebrate()
			d.on_collected()
	)

func _on_dessert_collected(points:int) -> void:
	score += points
	update_hud()

func _on_dessert_missed() -> void:
	lives -= 1
	update_hud()
	if lives <= 0:
		game_over()

func game_over() -> void:
	spawn_timer.stop()
	music.stop()
	var over := Label.new()
	over.text = "Game Over\nScore: %s\nPress R to restart" % score
	over.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	over.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	over.size = get_viewport_rect().size
	over.add_theme_color_override("font_color", Color.from_string("#2D9CDB", Color.SKY_BLUE))
	$CanvasLayer/HUD.add_child(over)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.physical_keycode == KEY_R):
		get_tree().reload_current_scene()
