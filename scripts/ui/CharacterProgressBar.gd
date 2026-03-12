extends Node2D
## 진행 바 - 전체 200×4, 현재 진행도 표시, 양 끝 원형 캡

var progress: float = 0.0  ## 0.0 ~ 1.0

func _draw() -> void:
	var bar_w: float = 200.0
	var bar_h: float = 4.0
	var r: float = bar_h / 2.0
	var left: float = -bar_w / 2

	# 배경 바 (양 끝 원형)
	draw_rect(Rect2(left + r, -r, bar_w - bar_h, bar_h), Color(1, 1, 1, 0.2))
	draw_circle(Vector2(left + r, 0), r, Color(1, 1, 1, 0.2))
	draw_circle(Vector2(-left - r, 0), r, Color(1, 1, 1, 0.2))

	# 진행 바
	var fill_w: float = (bar_w - bar_h) * clampf(progress, 0.0, 1.0)
	if fill_w > 0.001:
		draw_circle(Vector2(left + r, 0), r, Color(1, 1, 1, 1))
		if fill_w > r:
			draw_rect(Rect2(left + r, -r, fill_w - r, bar_h), Color(1, 1, 1, 1))
		if fill_w >= bar_w - bar_h - 0.01:
			draw_circle(Vector2(-left - r, 0), r, Color(1, 1, 1, 1))
		elif fill_w > r:
			draw_circle(Vector2(left + fill_w, 0), r, Color(1, 1, 1, 1))
