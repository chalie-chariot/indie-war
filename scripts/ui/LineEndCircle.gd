extends Control
## 양쪽 끝 검은 원 (라인과 겹치지 않음)

const DIAMETER: int = 20

func _ready() -> void:
	custom_minimum_size = Vector2(DIAMETER + 8, DIAMETER + 8)

func _draw() -> void:
	var center: Vector2 = size / 2
	var radius: float = float(DIAMETER) / 2.0
	# 검은 원
	draw_circle(center, radius, Color(0, 0, 0, 1))
	# 은은한 흰 테두리
	draw_arc(center, radius - 0.5, 0, TAU, 24, Color(1, 1, 1, 0.3))
