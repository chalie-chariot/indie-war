extends Control
## DiagLines - 대각선 장식 2개

const LINE_COLOR := Color("#e8c84a")
const LINE_OPACITY := 0.15  # 적당한 투명도로 장식

func _draw() -> void:
	var sz := size
	if sz.x <= 0 or sz.y <= 0:
		return
	var color := LINE_COLOR
	color.a = LINE_OPACITY
	# 대각선 2개: 좌상→우하, 우상→좌하
	draw_line(Vector2.ZERO, sz, color)
	draw_line(Vector2(sz.x, 0), Vector2(0, sz.y), color)
