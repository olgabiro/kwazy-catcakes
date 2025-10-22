extends Node
class_name GameTheme

var colors: Dictionary = {}

func _ready() -> void:
	load_colors()

func load_colors() -> void:
	var path := "res://assets/colors.json"
	if not FileAccess.file_exists(path):
		push_warning("colors.json not found, using defaults")
		colors = {
			"bg": "#F1F1F1",
			"accent": "#FFD93D",
			"text": "#6A6A6A"
		}
		return
	var file := FileAccess.open(path, FileAccess.READ)
	var text := file.get_as_text()
	var data: Variant = JSON.parse_string(text)
	if data is Dictionary:
		colors = data
	else:
		push_warning("Invalid JSON in colors.json, using fallback")
		colors = {"bg": "#F1F1F1", "accent": "#FFD93D", "text": "#7A7D8C"}
