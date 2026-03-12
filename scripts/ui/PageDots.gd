extends Control
## 하단 페이지 도트 4개 - 현재 페이지 흰색 크게, 나머지 회색 작게

var active_index: int = 0
const DOT_R: float = 6.0
const INACTIVE_R: float = 4.0
const SPACING: float = 16.0

func _draw() -> void:
	var total_w: float = 3.0 * SPACING + 2.0 * DOT_R
	var start_x: float = (size.x - total_w) / 2.0 + DOT_R
	var cy: float = size.y / 2.0
	for i in 4:
		var x: float = start_x + i * SPACING
		var pos := Vector2(x, cy)
		if i == active_index:
			draw_circle(pos, DOT_R, Color(1, 1, 1, 1))
		else:
			draw_circle(pos, INACTIVE_R, Color(0.5, 0.5, 0.5, 1))
