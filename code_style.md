# Code Guidelines (Godot / GDScript)

- Use GDScript, not C#.
- Scene hierarchy:
  - `Main` scene loads `Board`, `UI`, and `Audio`.
  - Each tile is a `Tile.tscn` with a script.
- Use snake_case for variables.
- Keep constants at top of scripts.
- One responsibility per script.
- Comment logic blocks briefly.