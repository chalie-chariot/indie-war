extends Control
## 반짝이는 아이콘 - 클릭 시 SkillSetInfo로 이동

signal clicked

const ICON_SIZE: float = 48.0
const GLOW_RADIUS: float = 56.0
const HOVER_SCALE: float = 1.5
const ROTATION_TURNS: float = 1.0
const ROTATION_DURATION: float = 1.0

var _hover_tween: Tween
var _rotate_tween: Tween

func _ready() -> void:
	custom_minimum_size = Vector2(100, 100)
	_resize_pivot()
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(_resize_pivot)
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))

func _resize_pivot() -> void:
	var s := size
	if s.x <= 0 or s.y <= 0:
		s = custom_minimum_size
	pivot_offset = s * 0.5

func _on_hover(enter: bool) -> void:
	_resize_pivot()
	if _hover_tween:
		_hover_tween.kill()
	if _rotate_tween:
		_rotate_tween.kill()
	if enter:
		_hover_tween = create_tween()
		_hover_tween.tween_property(self, "scale", Vector2(HOVER_SCALE, HOVER_SCALE), 0.2).set_ease(Tween.EASE_OUT)
		_rotate_tween = create_tween()
		_rotate_tween.tween_method(_set_rotation, 0.0, ROTATION_TURNS * TAU, ROTATION_DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	else:
		_hover_tween = create_tween()
		_hover_tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT)
		rotation = 0.0

func _set_rotation(rad: float) -> void:
	rotation = rad

func _draw() -> void:
	var center: Vector2 = size * 0.5
	# 바깥 글로우
	for i in 8:
		var t: float = float(i) / 8.0
		var r: float = lerpf(GLOW_RADIUS, ICON_SIZE * 0.5, t)
		var a: float = lerpf(0.05, 0.0, t)
		draw_arc(center, r, 0, TAU, 32, Color(1, 1, 1, a), 2.0)
	# 4방향 별 모양
	var star_points: PackedVector2Array = []
	for i in 8:
		var angle: float = deg_to_rad(i * 45.0 - 90.0)
		var dist: float = ICON_SIZE * 0.5 if i % 2 == 0 else ICON_SIZE * 0.2
		star_points.append(center + Vector2(cos(angle), sin(angle)) * dist)
	if star_points.size() >= 3:
		draw_colored_polygon(star_points, Color(1, 1, 1, 0.9))
	# 테두리
	draw_arc(center, ICON_SIZE * 0.5, 0, TAU, 24, Color(1, 1, 1, 0.8), 2.0)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit()
		accept_event()
