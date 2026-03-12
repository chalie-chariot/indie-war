extends Control
## EclipseCircle - 월식 반원 + 곡선 따라 하얀 마름모 6개 (메뉴별 광원)

const CIRCLE_DIAMETER := 1200
const CIRCLE_RADIUS := 600
const CENTER_X_OFFSET := 900
const CENTER_Y := 1180
const GLOW_OUTER_RANGE := 60

# 반원 곡선(상단 반원) 기준 마름모
const DIAMOND_COUNT := 6
const DIAMOND_SIZE := 9.0
const DIAMOND_ARC_OFFSET := 45.0  # 반원과 거리 두기 (바깥쪽으로)
var _active_diamond: int = 0
var _animated_diamond: float = 0.0
var _diamond_tween: Tween = null

func set_active_index(idx: int) -> void:
	_active_diamond = idx
	if _diamond_tween and _diamond_tween.is_running():
		_diamond_tween.kill()
	_diamond_tween = create_tween()
	_diamond_tween.tween_property(self, "_animated_diamond", float(idx), 0.25).set_ease(Tween.EASE_OUT)
	queue_redraw()

func _process(_delta: float) -> void:
	if _diamond_tween and _diamond_tween.is_running():
		queue_redraw()

func _get_diamond_center(i: int) -> Vector2:
	var center := Vector2(CENTER_X_OFFSET, CENTER_Y)
	# 상단 반원 곡선에 등분: 180°(왼쪽) → 330°(오른쪽), 6등분
	var deg: float = 180.0 + float(i) * 30.0
	var rad: float = deg * PI / 180.0
	var dir: Vector2 = Vector2(cos(rad), sin(rad))
	return center + (CIRCLE_RADIUS + DIAMOND_ARC_OFFSET) * dir

func _draw() -> void:
	var center := Vector2(CENTER_X_OFFSET, CENTER_Y)
	var radius := CIRCLE_RADIUS
	
	# 1. 검정 채우기
	draw_circle(center, radius, Color("#000000"))
	
	# 2. 바깥 글로우만
	for i in range(GLOW_OUTER_RANGE):
		var t := 1.0 - float(i) / GLOW_OUTER_RANGE
		draw_arc(center, radius + i, 0, TAU, 64, Color(1, 1, 1, 0.15 * t))
	
	# 3. 흰색 외곽선 (2px)
	draw_arc(center, radius, 0, TAU, 64, Color.WHITE)
	draw_arc(center, radius - 1, 0, TAU, 64, Color.WHITE)
	
	# 4. 반원 곡선 따라 하얀 마름모 6개 (딱 마름모만, 기울기 없음, 투명도 없음)
	for i in DIAMOND_COUNT:
		var pos: Vector2 = _get_diamond_center(i)
		_draw_diamond(pos, DIAMOND_SIZE)

func _draw_diamond(at: Vector2, sz: float) -> void:
	# 정 마름모 (정사각형 45° 회전): 위·오른쪽·아래·왼쪽 꼭지점
	var pts: PackedVector2Array = [
		at + Vector2(0, -sz),
		at + Vector2(sz, 0),
		at + Vector2(0, sz),
		at + Vector2(-sz, 0)
	]
	draw_colored_polygon(pts, Color(1, 1, 1, 1))
