extends Node2D
## 상세보기 버튼용 마름모 1개 (흰색 채움)

const SIZE: float = 10.0

func _draw() -> void:
	var pts: PackedVector2Array = [
		Vector2(0, -SIZE),
		Vector2(SIZE, 0),
		Vector2(0, SIZE),
		Vector2(-SIZE, 0)
	]
	draw_colored_polygon(pts, Color(1, 1, 1, 1))
