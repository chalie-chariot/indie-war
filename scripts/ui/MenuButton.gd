extends Control
## MenuButton - 흰색 원만 (14px, 60%), hover 18px 100% + 글로우

@export var button_index: int = 1

var _hovered := false
var _selected := false

signal pressed(index: int)

const DIAMETER_NORMAL := 14
const DIAMETER_HOVER := 18
const OPACITY_NORMAL := 0.6
const GLOW_RADIUS := 8

func _ready() -> void:
	custom_minimum_size = Vector2(36, 36)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func set_selected(value: bool) -> void:
	_selected = value
	queue_redraw()

func _draw() -> void:
	var center := size / 2
	var diam := DIAMETER_HOVER if (_hovered or _selected) else DIAMETER_NORMAL
	var radius := diam / 2.0
	var alpha := 1.0 if (_hovered or _selected) else OPACITY_NORMAL
	
	if _hovered or _selected:
		for i in range(GLOW_RADIUS, 0, -1):
			var glow_alpha := 0.25 * (1.0 - float(i) / GLOW_RADIUS)
			draw_arc(center, radius + i, 0, TAU, 32, Color(1, 1, 1, glow_alpha))
	
	draw_arc(center, radius, 0, TAU, 32, Color(1, 1, 1, alpha))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			if _is_point_inside(get_local_mouse_position()):
				pressed.emit(button_index)

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		_hovered = true
		queue_redraw()
	elif what == NOTIFICATION_MOUSE_EXIT:
		_hovered = false
		queue_redraw()

func _is_point_inside(point: Vector2) -> bool:
	var center := size / 2
	return point.distance_to(center) <= DIAMETER_HOVER
