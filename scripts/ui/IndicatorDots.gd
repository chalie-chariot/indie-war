extends Control
## 인디케이터 6개 - 하단 상단 1개가 은은하게 발광, 메뉴 전환 시 천천히 소멸→다음 발광

const DOT_COUNT: int = 6
const CIRCLE_RADIUS: float = 80.0
const TRANSITION_DURATION: float = 0.45  # 천천히
const ANGLE_STEP: float = TAU / 6.0

var _active_index: int = 0
var _prev_index: int = -1
var _fade_in: float = 1.0   # 새 활성 점 발광 강도 0→1
var _fade_out: float = 0.0  # 기존 점 소멸 1→0
var _transition_tween: Tween = null

func _ready() -> void:
	queue_redraw()

func set_active_index(idx: int, _clockwise: bool = true) -> void:
	if idx == _active_index:
		return
	_prev_index = _active_index
	_active_index = idx
	_fade_in = 0.0
	_fade_out = 1.0
	if _transition_tween and _transition_tween.is_running():
		_transition_tween.kill()
	_transition_tween = create_tween()
	_transition_tween.set_parallel(true)
	_transition_tween.tween_property(self, "_fade_in", 1.0, TRANSITION_DURATION).set_ease(Tween.EASE_OUT)
	_transition_tween.tween_property(self, "_fade_out", 0.0, TRANSITION_DURATION).set_ease(Tween.EASE_IN)

func _process(_delta: float) -> void:
	if _transition_tween and _transition_tween.is_running():
		queue_redraw()

func _get_center() -> Vector2:
	return size / 2.0

func _get_dot_pos(index: int) -> Vector2:
	var center: Vector2 = _get_center()
	var angle: float = -PI / 2.0 + float(index) * ANGLE_STEP
	return center + Vector2(cos(angle), sin(angle)) * CIRCLE_RADIUS

## 은은한 광원 - 여러 겹으로 부드럽게 발광 (딱딱한 원 X)
func _draw_glow(pos: Vector2, intensity: float) -> void:
	if intensity <= 0.0:
		return
	# 바깥에서 안쪽으로 부드러운 그라데이션 (광원 넓게 퍼짐)
	var layers: Array = [28.0, 22.0, 17.0, 13.0, 10.0, 8.0, 6.0, 4.5, 3.0]
	var alphas: Array = [0.02, 0.04, 0.07, 0.12, 0.20, 0.32, 0.48, 0.65, 0.82]
	for i in layers.size():
		var a: float = alphas[i] * intensity
		draw_circle(pos, layers[i], Color(1, 1, 1, a))

func _draw() -> void:
	for i in DOT_COUNT:
		var pos: Vector2 = _get_dot_pos(i)
		# 모든 점에 평범한 원 베이스 (빛 소멸 후에도 그대로 남음)
		draw_circle(pos, 4.0, Color(1, 1, 1, 0.22))
		# 활성/전환 중인 점에만 발광 레이어
		if i == _active_index:
			_draw_glow(pos, _fade_in)
		elif i == _prev_index and _prev_index >= 0:
			_draw_glow(pos, _fade_out)
