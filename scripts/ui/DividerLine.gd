extends Control
## 라인 세그먼트 - 기본 선만

func _draw() -> void:
	var cy: float = size.y / 2.0
	draw_line(Vector2(0, cy), Vector2(size.x, cy), Color(1, 1, 1, 0.3), 1.0)
