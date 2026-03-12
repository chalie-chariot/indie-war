extends Node2D
## 탭 인디케이터 3개 (정보 / 스킬 / 스탯)

var current_page: int = 0
signal page_changed(page: int)

func set_page(page: int) -> void:
	current_page = clampi(page, 0, 2)
	queue_redraw()
	page_changed.emit(current_page)

const RADIUS: float = 15.0
const SPACING: float = 60.0
const TOTAL: int = 3

func _draw() -> void:
	var start_y: float = -(TOTAL - 1) * SPACING * 0.5

	for i in TOTAL:
		var pos: Vector2 = Vector2(0, start_y + i * SPACING)
		if i == current_page:
			draw_circle(pos, RADIUS, Color(1, 1, 1, 1.0))
		else:
			draw_arc(pos, RADIUS, 0, TAU, 32, Color(1, 1, 1, 0.3), 3.6)
