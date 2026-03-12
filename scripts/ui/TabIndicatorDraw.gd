extends Node2D
## 좌하단 탭 인디케이터 - 상(qwer) 하(shift,passive) 세로 구분, 텍스트와 겹치지 않음

var current_tab: int = 0

const SIZE: float = 28.0  # 정사각형 (2배)
const GAP: float = 10.0

func set_tab(tab: int) -> void:
	current_tab = tab
	queue_redraw()

func _draw() -> void:
	var tab1_color: Color = Color(1, 1, 1, 1.0) if current_tab == 0 else Color(1, 1, 1, 0.25)
	var tab2_color: Color = Color(1, 1, 1, 1.0) if current_tab == 1 else Color(1, 1, 1, 0.25)
	# 상: qwer (정사각형)
	draw_rect(Rect2(0, 0, SIZE, SIZE), tab1_color)
	# 하: shift, passive (정사각형)
	draw_rect(Rect2(0, SIZE + GAP, SIZE, SIZE), tab2_color)

func is_point_in_rect1(point: Vector2) -> bool:
	var local: Vector2 = to_local(point)
	return Rect2(0, 0, SIZE, SIZE).has_point(local)

func is_point_in_rect2(point: Vector2) -> bool:
	var local: Vector2 = to_local(point)
	return Rect2(0, SIZE + GAP, SIZE, SIZE).has_point(local)
