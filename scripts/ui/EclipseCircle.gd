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
		d.glow_radius = 0.0
		d.glow_alpha = 0.0
		d.modulate.a = 0.2
		d.set_anchors_preset(Control.PRESET_TOP_LEFT)
		add_child(d)
		diamonds.append(d)

func set_active_index(idx: int) -> void:
	pass

func play_diamond_anim(direction: int) -> void:
	var order: Array = diamonds.duplicate()
	if direction == -1:
		order.reverse()

	for i in order.size():
		var d = order[i]
		var tween := create_tween()
		tween.tween_interval(i * 0.06)
		# 마름모에서 빛 발광 (범위·강도 증가)
		tween.tween_property(d, "modulate:a", 1.0, 0.18).from(0.2).set_ease(Tween.EASE_OUT)
		tween.tween_property(d, "glow_radius", 22.0, 0.18).from(0.0).set_ease(Tween.EASE_OUT)
		tween.tween_property(d, "glow_alpha", 1.0, 0.18).from(0.0).set_ease(Tween.EASE_OUT)
		# 잔상 유지
		tween.tween_interval(0.12)
		# 천천히 소멸
		tween.tween_property(d, "modulate:a", 0.2, 0.25).set_ease(Tween.EASE_IN)
		tween.tween_property(d, "glow_radius", 0.0, 0.25).set_ease(Tween.EASE_IN)
		tween.tween_property(d, "glow_alpha", 0.0, 0.25).set_ease(Tween.EASE_IN)

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
