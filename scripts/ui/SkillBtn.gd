extends Control
## 스킬 버튼 - 원형, 호버/클릭 시 확대

var key: String = "Q"
var is_selected: bool = false
signal pressed(key: String)

const BTN_RADIUS: float = 30.0

func _ready() -> void:
	custom_minimum_size = Vector2(64, 64)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup(k: String) -> void:
	key = k

func _draw() -> void:
	var center: Vector2 = size * 0.5
	var border_alpha: float = 1.0 if is_selected else 0.8
	draw_circle(center, BTN_RADIUS, Color(0.15, 0.15, 0.15, 1))
	draw_arc(center, BTN_RADIUS, 0, TAU, 64, Color(1, 1, 1, border_alpha), 2.0)
	var font: Font = ThemeDB.fallback_font
	var str_size: Vector2 = font.get_string_size(key)
	var pos: Vector2 = center - Vector2(str_size.x * 0.5, -font.get_ascent() * 0.5)
	draw_string(font, pos, key)

func _on_mouse_entered() -> void:
	var t := create_tween()
	t.tween_property(self, "scale", Vector2(1.3, 1.3), 0.15)

func _on_mouse_exited() -> void:
	if not is_selected:
		var t := create_tween()
		t.tween_property(self, "scale", Vector2.ONE, 0.15)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit(key)
		accept_event()
