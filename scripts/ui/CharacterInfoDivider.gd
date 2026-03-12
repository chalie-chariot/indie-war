extends Node2D
## 구분선 - 메뉴명/역할 아래

func _draw() -> void:
	draw_line(Vector2(0, 0), Vector2(500, 0), Color(1, 1, 1, 0.15), 1.0)
