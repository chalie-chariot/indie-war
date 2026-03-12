extends Control
## 스크롤 인디케이터 - 빈 원 N개 + 현재 채워진 흰색 원

signal index_selected(index: int)

var dot_count: int = 5
var active_index: int = 0
const DOT_RADIUS: float = 4.0
const DOT_SPACING: float = 12.0

func _draw() -> void:
	var total_h: float = dot_count * (DOT_RADIUS * 2.0) + (dot_count - 1) * DOT_SPACING
	var start_y: float = (size.y - total_h) / 2.0 + DOT_RADIUS
	var cx: float = size.x / 2.0

	for i in dot_count:
		var y: float = start_y + i * (DOT_RADIUS * 2.0 + DOT_SPACING)
		var pos := Vector2(cx, y)
		if i == active_index:
			draw_circle(pos, DOT_RADIUS, Color(1, 1, 1, 1))
		else:
			var pts: PackedVector2Array = []
			for j in 17:
				var a: float = j * TAU / 16.0
				pts.append(pos + Vector2(cos(a), sin(a)) * DOT_RADIUS)
			draw_polyline(pts, Color(1, 1, 1, 0.5))

func set_active(index: int) -> void:
	active_index = clampi(index, 0, dot_count - 1)
	queue_redraw()

func set_dot_count(count: int) -> void:
	dot_count = maxi(1, count)
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			var total_h: float = dot_count * (DOT_RADIUS * 2.0) + (dot_count - 1) * DOT_SPACING
			var start_y: float = (size.y - total_h) / 2.0 + DOT_RADIUS
			var cx: float = size.x / 2.0
			var pos: Vector2 = get_local_mouse_position()
			for i in dot_count:
				var y: float = start_y + i * (DOT_RADIUS * 2.0 + DOT_SPACING)
				var dot_pos := Vector2(cx, y)
				if pos.distance_to(dot_pos) <= DOT_RADIUS * 2.0:
					index_selected.emit(i)
					accept_event()
					break
