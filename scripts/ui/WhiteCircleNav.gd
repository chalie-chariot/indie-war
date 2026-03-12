extends Control
## 하얀 원 + 광원 (검은 원 맞은편, 바깥쪽) - 클릭 시 prev/next

@export var is_prev: bool = true

signal pressed

var _hovered: bool = false

const DIAMETER: int = 20
const GLOW_RADIUS: int = 8

func _ready() -> void:
	custom_minimum_size = Vector2(44, 44)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_filter = Control.MOUSE_FILTER_STOP

func _draw() -> void:
	var center: Vector2 = size / 2
	var radius: float = (float(DIAMETER) if not _hovered else 24.0) / 2.0
	# 하얀 광원
	for i in range(GLOW_RADIUS, 0, -1):
		var alpha: float = (0.35 if _hovered else 0.2) * (1.0 - float(i) / float(GLOW_RADIUS))
		draw_circle(center, radius + i, Color(1, 1, 1, alpha))
	# 하얀 원
	draw_circle(center, radius, Color(1, 1, 1, 1))
	# 은은한 테두리
	draw_arc(center, radius - 0.5, 0, TAU, 24, Color(0.3, 0.3, 0.3, 0.5))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			accept_event()
			pressed.emit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		_hovered = true
		queue_redraw()
	elif what == NOTIFICATION_MOUSE_EXIT:
		_hovered = false
		queue_redraw()
