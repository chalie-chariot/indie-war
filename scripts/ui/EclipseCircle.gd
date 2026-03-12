extends Control
## EclipseCircle - 월식 반원 + 곡선 따라 하얀 마름모 6개 (순차 발광)

const CIRCLE_DIAMETER := 1200
const CIRCLE_RADIUS := 600
const CENTER_X_OFFSET := 900
const CENTER_Y := 1180
const GLOW_OUTER_RANGE := 60

const DIAMOND_COUNT := 6
const DIAMOND_ARC_OFFSET := 45.0

var diamonds: Array = []
var _diamond_script: GDScript
var _active_tweens: Array = []

func _ready() -> void:
	_diamond_script = load("res://scripts/ui/DiamondShape.gd") as GDScript
	for i in DIAMOND_COUNT:
		var d: Control = Control.new()
		d.set_script(_diamond_script)
		d.name = "Diamond%d" % i
		var pos: Vector2 = _get_diamond_center(i)
		d.custom_minimum_size = Vector2(48, 48)
		d.size = Vector2(48, 48)
		d.position = pos - Vector2(24, 24)
		d.pivot_offset = Vector2(24, 24)
		d.glow_radius = 0.0
		d.glow_alpha = 0.0
		d.modulate.a = 0.2
		d.set_anchors_preset(Control.PRESET_TOP_LEFT)
		add_child(d)
		diamonds.append(d)

func set_active_index(idx: int) -> void:
	pass

func play_diamond_anim(direction: int) -> void:
	# 기존 트윈 정리·마름모 초기화 → 양방향 타이밍 동일
	for t in _active_tweens:
		if is_instance_valid(t) and t.is_valid():
			t.kill()
	_active_tweens.clear()
	for d in diamonds:
		d.modulate.a = 0.2
		d.scale = Vector2(1.0, 1.0)

	var order: Array = diamonds.duplicate()
	if direction == -1:
		order.reverse()

	const SCALE_FIRST: float = 2.0
	const SCALE_STEP: float = 0.16
	const INTERVAL: float = 0.22  # 커짐·작아짐 모두 순차 간격 동일
	const GLOW_UP: float = 0.32
	const HOLD: float = 0.22
	const FADE_OUT: float = 0.32
	for i in order.size():
		var d = order[i]
		var peak_scale: float = maxf(1.05, SCALE_FIRST - float(i) * SCALE_STEP)
		var tween := create_tween()
		_active_tweens.append(tween)
		tween.tween_interval(i * INTERVAL)
		tween.set_parallel(true)
		tween.tween_property(d, "modulate:a", 1.0, GLOW_UP).from(0.2).set_ease(Tween.EASE_OUT)
		tween.tween_property(d, "scale", Vector2(peak_scale, peak_scale), GLOW_UP).from(Vector2(1.0, 1.0)).set_ease(Tween.EASE_OUT)
		tween.set_parallel(false)
		tween.tween_interval(HOLD)
		tween.set_parallel(true)
		tween.tween_property(d, "modulate:a", 0.2, FADE_OUT).set_ease(Tween.EASE_IN)
		tween.tween_property(d, "scale", Vector2(1.0, 1.0), FADE_OUT).set_ease(Tween.EASE_IN)
		tween.set_parallel(false)

func _get_diamond_center(i: int) -> Vector2:
	var center := Vector2(CENTER_X_OFFSET, CENTER_Y)
	var deg: float = 180.0 + float(i) * 30.0
	var rad: float = deg * PI / 180.0
	var dir: Vector2 = Vector2(cos(rad), sin(rad))
	return center + (CIRCLE_RADIUS + DIAMOND_ARC_OFFSET) * dir

func _draw() -> void:
	var center := Vector2(CENTER_X_OFFSET, CENTER_Y)
	var radius := CIRCLE_RADIUS

	# 1. 검정 채우기
	draw_circle(center, radius, Color("#000000"))

	# 2. 바깥 글로우만
	for i in range(GLOW_OUTER_RANGE):
		var t := 1.0 - float(i) / GLOW_OUTER_RANGE
		draw_arc(center, radius + i, 0, TAU, 64, Color(1, 1, 1, 0.15 * t))

	# 3. 흰색 외곽선 (2px)
	draw_arc(center, radius, 0, TAU, 64, Color.WHITE)
	draw_arc(center, radius - 1, 0, TAU, 64, Color.WHITE)
	# 마름모는 별도 노드로 그리기
