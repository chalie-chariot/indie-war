extends Control
## NavCircleButton - 검은 원 + 하얀 광원 (좌우 네비게이션)

@export var is_prev: bool = true  # true: 이전, false: 다음

var _hovered: bool = false

signal pressed

const DIAMETER: int = 28
const GLOW_RADIUS: int = 8

func _ready() -> void:
	custom_minimum_size = Vector2(40, 40)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _draw() -> void:
	var center: Vector2 = size / 2
	var radius: float = (float(DIAMETER) if not _hovered else 32.0) / 2.0
	
	# 하얀 광원 (바깥쪽부터 안쪽으로 채운 원)
	for i in range(GLOW_RADIUS, 0, -1):
		var alpha: float = (0.35 if _hovered else 0.2) * (1.0 - float(i) / float(GLOW_RADIUS))
		draw_circle(center, radius + i, Color(1, 1, 1, alpha))
	
	# 검은 원
	draw_circle(center, radius, Color(0, 0, 0, 1))
	
	# 흰색 테두리 (은은하게)
	draw_arc(center, radius - 0.5, 0, TAU, 32, Color(1, 1, 1, 0.4))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			if _is_inside(get_local_mouse_position()):
				pressed.emit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		_hovered = true
		queue_redraw()
	elif what == NOTIFICATION_MOUSE_EXIT:
		_hovered = false
		queue_redraw()

func _is_inside(point: Vector2) -> bool:
	return point.distance_to(size / 2) <= min(size.x, size.y) / 2.0
