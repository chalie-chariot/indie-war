extends Node2D
## 아치형 흰색 원 - 스킬 UI 장식 (가운데로 갈수록 굵게, 탭별 장식 점)

var current_tab: int = 0  # 0=QWER, 1=PS (외부에서 설정)

const RADIUS: float = 750.0
const ARC_START: float = 210.0
const ARC_END: float = 330.0
const ARC_END_WIDTH: float = 2.0  # 양 끝 굵기
const ARC_CENTER_WIDTH: float = 10.0  # 가운데(270°) 굵기

func set_tab(tab: int) -> void:
	current_tab = tab
	queue_redraw()

func _draw() -> void:
	# 호 굵기: 가운데(270°)로 갈수록 굵게 - 구간별로 그리기
	const SEGMENTS: int = 24
	var angle_step: float = (ARC_END - ARC_START) / float(SEGMENTS)
	for i in range(SEGMENTS):
		var a_start: float = ARC_START + i * angle_step
		var a_end: float = a_start + angle_step
		var a_mid: float = (a_start + a_end) / 2.0
		# 270°에 가까울수록 굵게 (abs(270 - a_mid) 기반)
		var dist_from_center: float = abs(270.0 - a_mid) / 60.0  # 0~1
		var w: float = lerpf(ARC_CENTER_WIDTH, ARC_END_WIDTH, clampf(dist_from_center, 0.0, 1.0))
		draw_arc(
			Vector2.ZERO,
			RADIUS,
			deg_to_rad(a_start),
			deg_to_rad(a_end),
			8,
			Color(1, 1, 1, 0.9),
			w
		)
