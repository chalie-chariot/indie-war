extends Node2D
## 스크롤 위치 인디케이터 - 흰 원이 스크롤 량에 따라 상하 이동

var scroll_ratio: float = 0.0  ## 0=top, 1=bottom

func set_scroll_ratio(ratio: float) -> void:
	scroll_ratio = clampf(ratio, 0.0, 1.0)
	queue_redraw()

const RADIUS: float = 15.0
const SPACING: float = 60.0
const TOTAL: int = 5

func _draw() -> void:
	var start_y: float = -(TOTAL - 1) * SPACING * 0.5
	var top_y: float = start_y
	var bottom_y: float = start_y + (TOTAL - 1) * SPACING

	# 고정 도트 5개 (테두리)
	for i in TOTAL:
		var pos: Vector2 = Vector2(0, start_y + i * SPACING)
		draw_arc(pos, RADIUS, 0, TAU, 32, Color(1, 1, 1, 0.3), 3.6)

	# 흰 채움 원 - 스크롤 비율에 따라 Y 보간 (top~bottom 제한)
	var fill_y: float = lerpf(top_y, bottom_y, scroll_ratio)
	draw_circle(Vector2(0, fill_y), RADIUS, Color(1, 1, 1, 1.0))
