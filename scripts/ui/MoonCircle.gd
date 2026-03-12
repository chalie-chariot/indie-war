extends Node2D
## 월식 원 - 태양 + 달(phase_offset) 표시

var phase_offset: float = 0.0
var at_end: bool = false  ## 스크롤 끝일 때 흰색 원 띠 표시

func _draw() -> void:
	if at_end:
		# 흰색 원 띠: 바깥 흰색 원 - 안쪽 배경색 원
		const R_OUTER: float = 52.0
		const R_INNER: float = 46.0
		draw_circle(Vector2.ZERO, R_OUTER, Color(1, 1, 1, 1))
		draw_circle(Vector2.ZERO, R_INNER, Color(0.118, 0.118, 0.118, 1))
	else:
		draw_circle(Vector2.ZERO, 52.0, Color(1, 1, 1, 1))
		draw_circle(Vector2(phase_offset, 0), 54.0, Color(0.12, 0.12, 0.12, 1))
