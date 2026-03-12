extends Control
## IndicatorDots - 6각형 꼭지점 형태 인디케이터 6개

const DOT_COUNT: int = 6
const HEX_RADIUS: float = 50.0  # 6각형 반지름
const DOT_DIAMETER: float = 10.0
const ACTIVE_DIAMETER: float = 14.0
const ACTIVE_GLOW: float = 6.0

var _active_index: int = 0
var _animated_index: float = 0.0
var _tween: Tween = null

func _ready() -> void:
	_animated_index = float(_active_index)

func _process(_delta: float) -> void:
	if _tween and _tween.is_running():
		queue_redraw()

func set_active_index(idx: int) -> void:
	_active_index = idx
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "_animated_index", float(idx), 0.2).set_ease(Tween.EASE_OUT)
	queue_redraw()

func _draw() -> void:
	var center_x: float = size.x / 2.0
	var center_y: float = size.y / 2.0
	
	for i in DOT_COUNT:
		var t: float = _get_lerp_for_index(float(i))
		var diam: float = lerpf(DOT_DIAMETER, ACTIVE_DIAMETER, t)
		var alpha: float = lerpf(0.3, 1.0, t)
		# 6각형 꼭지점 (맨 위가 인덱스 0, 시계방향으로 1~5)
		var angle: float = -TAU / 4.0 + float(i) * TAU / 6.0
		var dx: float = center_x + HEX_RADIUS * cos(angle)
		var dy: float = center_y + HEX_RADIUS * sin(angle)
		var center: Vector2 = Vector2(dx, dy)
		
		if t > 0.3:
			for j in range(int(ACTIVE_GLOW), 0, -1):
				var ga: float = 0.25 * (1.0 - float(j) / ACTIVE_GLOW) * t
				draw_circle(center, diam / 2.0 + j, Color(1, 1, 1, ga))
		draw_circle(center, diam / 2.0, Color(1, 1, 1, alpha))

func _get_lerp_for_index(idx: float) -> float:
	var dist: float = abs(idx - _animated_index)
	if dist < 0.01:
		return 1.0
	if dist > 1.0:
		return 0.0
	return 1.0 - dist
