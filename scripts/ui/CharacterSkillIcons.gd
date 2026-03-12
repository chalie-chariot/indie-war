extends Control
## 스킬 아이콘 4개 (Q/W/E/R) - 현재 원으로 대체

const KEYS: PackedStringArray = ["Q", "W", "E", "R"]
const RADIUS: float = 36.0
const SPACING: float = 100.0

func _ready() -> void:
	custom_minimum_size = Vector2(400, 80)

func _draw() -> void:
	var start_x: float = size.x * 0.5 - (4 - 1) * SPACING * 0.5
	var cy: float = size.y * 0.5
	var font: Font = ThemeDB.fallback_font
	var font_size: int = 18

	for i in 4:
		var cx: float = start_x + i * SPACING
		var pos: Vector2 = Vector2(cx, cy)
		draw_arc(pos, RADIUS, 0, TAU, 32, Color(1, 1, 1, 0.2), 2.0)
		draw_arc(pos, RADIUS - 2, 0, TAU, 32, Color(1, 1, 1, 0.4), 1.5)
		var key: String = KEYS[i]
		var str_size: Vector2 = font.get_string_size(key)
		draw_string(font, pos - str_size * 0.5, key)
