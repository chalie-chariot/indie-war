extends Control
## 라인 세그먼트 1개 (빛 애니메이션용)
## parent에서 light_pos 0~1 받아서 그리기

var segment_index: int = 0  # 0=왼쪽, 1=오른쪽
var light_pos: float = -1.0  # 0~1 이 세그먼트 내 위치, -1이면 빛 없음

const LINE_HEIGHT: float = 1.0
const GLOW_HEIGHT: int = 8
const LIGHT_WIDTH: float = 60.0
const LIGHT_HEIGHT: float = 5.0

func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	var line_y: float = h / 2.0 - LINE_HEIGHT / 2.0

	# 기본선: 1px, 30%
	draw_rect(Rect2(0, line_y, w, LINE_HEIGHT), Color(1, 1, 1, 0.3))
	# 아래 광원
	for i in range(GLOW_HEIGHT):
		var alpha: float = 0.15 * (1.0 - float(i) / GLOW_HEIGHT)
		draw_rect(Rect2(0, line_y + LINE_HEIGHT + i, w, 1), Color(1, 1, 1, alpha))

	# 빛: light_pos 0~1 이 이 세그먼트에서의 위치
	if light_pos >= 0 and light_pos <= 1:
		var lx: float = light_pos * w
		draw_set_transform(Vector2(lx, line_y + LINE_HEIGHT / 2.0), 0, Vector2(1.0, LIGHT_HEIGHT / LIGHT_WIDTH))
		for i in range(6, 0, -1):
			var r: float = 4.0 * i
			var glow: float = 0.3 * (1.0 - float(i) / 7.0)
			draw_circle(Vector2.ZERO, r, Color(1, 1, 1, glow))
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
