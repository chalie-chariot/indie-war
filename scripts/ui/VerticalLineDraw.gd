extends Node2D
## 좌하단 세로선 장식

func _draw() -> void:
	draw_line(Vector2(0, 0), Vector2(0, 60), Color(1, 1, 1, 0.8), 3.0)
