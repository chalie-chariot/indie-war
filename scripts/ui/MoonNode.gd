extends Node2D
## 달 - 클리핑 방식으로 초승달→보름달. 배경색 원으로 덮어서 초승달 형태

var cover_offset: float = 96.0
## 처음엔 배경색 원이 달을 거의 다 덮음 (초승달)
## 태양에 가까워질수록 0.0으로 줄어들며 보름달이 됨

var mask_color: Color = Color(1, 1, 1, 1)
## 덮는 원의 색상 (배경색과 동일하게 설정)

func _draw() -> void:
	var moon_radius: float = 52.0

	# 1. 달 본체 (검정)
	draw_circle(Vector2.ZERO, moon_radius, Color(0, 0, 0, 1.0))

	# 2. 배경색 원으로 달을 덮어서 초승달 형태 만들기
	#    cover_offset 만큼 오른쪽으로 이동한 원이 달의 오른쪽 부분을 가림
	draw_circle(Vector2(cover_offset, 0), moon_radius + 2.0, mask_color)
