extends Control
## 반짝이는 아이콘 - 클릭 시 SkillSetInfo로 이동

signal clicked

const ICON_SIZE: float = 48.0
const GLOW_RADIUS: float = 56.0

func _ready() -> void:
	custom_minimum_size = Vector2(100, 100)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))

func _on_hover(enter: bool) -> void:
	var t := create_tween()
	t.tween_property(self, "scale", Vector2(1.15, 1.15) if enter else Vector2.ONE, 0.15)

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
