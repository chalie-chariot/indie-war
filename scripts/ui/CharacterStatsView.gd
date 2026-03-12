extends Control
## 캐릭터 스탯 - 5각형 레이더 + 막대 게이지

## 스탯 5종: [공격, 방어, 속도, 링크, 생존]
var stats: Array[float] = [0.8, 0.7, 0.6, 0.9, 0.75]

const PENTAGON_RADIUS: float = 80.0
const BAR_COUNT: int = 5
const BAR_NAMES: PackedStringArray = ["공격", "방어", "속도", "링크", "생존"]
const BAR_HEIGHT: float = 24.0
const BAR_WIDTH: float = 200.0
const BAR_GAP: float = 8.0

func _ready() -> void:
	custom_minimum_size = Vector2(300, 320)

func set_stats(values: Array) -> void:
	for i in min(values.size(), 5):
		stats[i] = clampf(float(values[i]), 0.0, 1.0)
	queue_redraw()

func _draw() -> void:
	var center: Vector2 = Vector2(size.x * 0.5, 120.0)

	# 5각형 레이더 차트
	_draw_pentagon(center)

	# 막대 게이지 (5각형 아래)
	var bar_start_y: float = center.y + PENTAGON_RADIUS + 40.0
	for i in BAR_COUNT:
		var by: float = bar_start_y + i * (BAR_HEIGHT + BAR_GAP)
		_draw_bar(Vector2(size.x * 0.5 - BAR_WIDTH * 0.5, by), stats[i])

func _draw_pentagon(center: Vector2) -> void:
	var points: PackedVector2Array = []
	for i in 5:
		var angle: float = -PI * 0.5 + i * TAU / 5.0
		var r: float = PENTAGON_RADIUS * stats[i]
		points.append(center + Vector2(cos(angle), sin(angle)) * r)

	# 배경 그리드 (5각형)
	for i in 5:
		var j: int = (i + 1) % 5
		draw_line(center, center + (points[i] - center).normalized() * PENTAGON_RADIUS, Color(1, 1, 1, 0.15), 1.0)
	draw_polyline(points, Color(1, 1, 1, 0.4), 2.0)
	draw_colored_polygon(points, Color(1, 1, 1, 0.08))

func _draw_bar(pos: Vector2, ratio: float) -> void:
	var fill_w: float = BAR_WIDTH * clampf(ratio, 0.0, 1.0)
	# 배경
	draw_rect(Rect2(pos, Vector2(BAR_WIDTH, BAR_HEIGHT)), Color(1, 1, 1, 0.15))
	# 채움
	if fill_w > 2.0:
		draw_rect(Rect2(pos, Vector2(fill_w, BAR_HEIGHT)), Color(1, 1, 1, 0.6))
