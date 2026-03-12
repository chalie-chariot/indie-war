extends Node2D
## 아치형 흰색 원 - 스킬 UI 장식

const RADIUS: float = 580.0
const DOT_RADIUS: float = 4.0
const DOT_DIST: float = 590.0
const DOT_ANGLES: Array = [-75, -60, -45, 45, 60, 75]

func _draw() -> void:
	# 흰색 원 호 (상단 절반만)
	draw_arc(
		Vector2.ZERO,
		RADIUS,
		deg_to_rad(195.0),
		deg_to_rad(345.0),
		128,
		Color(1, 1, 1, 0.9),
		2.0
	)
	# 원 위 점들 (장식)
	for a in DOT_ANGLES:
		var rad: float = deg_to_rad(a - 90.0)
		var pos: Vector2 = Vector2(cos(rad), sin(rad)) * DOT_DIST
		draw_circle(pos, DOT_RADIUS, Color(1, 1, 1, 0.8))
