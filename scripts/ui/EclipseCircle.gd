extends Control
## EclipseCircle - 월식 반원 (참고 이미지 스펙)

# 화면 전체 기준 중심: X 1300, Y 1180 (부모 RightArea 기준으로 변환)
const CIRCLE_DIAMETER := 1200
const CIRCLE_RADIUS := 600
const CENTER_X_OFFSET := 900   # RightArea(400~) 기준: 400+900=1300
const CENTER_Y := 1180

# 강화 글로우: 안쪽 200px, 바깥 60px
const GLOW_INNER_RANGE := 200
const GLOW_OUTER_RANGE := 60

# 중앙 발광점
const MAIN_GLOW_RADIUS := 6
const MAIN_GLOW_SPREAD := 16
const SUB_DOT_RADIUS := 3
const SUB_DOT_SPACING := 60

func _draw() -> void:
	var center := Vector2(CENTER_X_OFFSET, CENTER_Y)
	var radius := CIRCLE_RADIUS
	
	# 1. 검정 채우기
	draw_circle(center, radius, Color("#000000"))
	
	# 2. 바깥 글로우 (경계에서 바깥 60px, 흰색→투명)
	for i in range(GLOW_OUTER_RANGE):
		var t := 1.0 - float(i) / GLOW_OUTER_RANGE
		draw_arc(center, radius + i, 0, TAU, 64, Color(1, 1, 1, 0.15 * t))
	
	# 3. 안쪽 방사형 글로우 (경계에서 안 200px, 흰색→투명)
	for i in range(GLOW_INNER_RANGE):
		var t := 1.0 - float(i) / GLOW_INNER_RANGE
		draw_arc(center, radius - i, 0, TAU, 64, Color(1, 1, 1, 0.25 * t))
	
	# 4. 흰색 외곽선 (2px)
	draw_arc(center, radius, 0, TAU, 64, Color.WHITE)
	draw_arc(center, radius - 1, 0, TAU, 64, Color.WHITE)
	
	# 5. 중앙 발광점 (살짝 위, 지름 12px + 글로우)
	var main_center := center + Vector2(0, -radius * 0.25)
	for i in range(MAIN_GLOW_SPREAD, 0, -1):
		var alpha := 0.4 * (1.0 - float(i) / MAIN_GLOW_SPREAD)
		draw_circle(main_center, MAIN_GLOW_RADIUS + i, Color(1, 1, 1, alpha))
	draw_circle(main_center, MAIN_GLOW_RADIUS, Color(1, 1, 1, 0.9))
	
	# 6. 하단 2×2 작은 원 4개 (간격 60px)
	var grid_center := main_center + Vector2(0, 90)
	var half := SUB_DOT_SPACING / 2.0
	var dots := [
		grid_center + Vector2(-half, -half),
		grid_center + Vector2(half, -half),
		grid_center + Vector2(-half, half),
		grid_center + Vector2(half, half)
	]
	for pt in dots:
		draw_circle(pt, SUB_DOT_RADIUS, Color(1, 1, 1, 0.3))
