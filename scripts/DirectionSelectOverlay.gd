extends CanvasLayer
## Q 스킬 방향 선택 UI - 4방향 화살표 오버레이

const TILE_SIZE: int = 80
const ARROW_SIZE: int = 48

var map_node: Node2D = null
var unit_grid_pos: Vector2i = Vector2i.ZERO
var arrow_buttons: Array[Button] = []
var back_panel: ColorRect = null  # 클릭 시 취소용

func _ready() -> void:
	visible = false
	_setup_ui()

func _setup_ui() -> void:
	if back_panel != null:
		return
	# 전체 화면 클릭 시 취소용 (투명)
	back_panel = ColorRect.new()
	back_panel.color = Color(0, 0, 0, 0.01)
	back_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	back_panel.gui_input.connect(_on_background_gui_input)
	back_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(back_panel)

	# 4방향 화살표
	var dirs = [
		{"dir": Vector2i(0, -1), "text": "▲", "name": "Up"},
		{"dir": Vector2i(0, 1), "text": "▼", "name": "Down"},
		{"dir": Vector2i(-1, 0), "text": "◀", "name": "Left"},
		{"dir": Vector2i(1, 0), "text": "▶", "name": "Right"},
	]
	for d in dirs:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(ARROW_SIZE, ARROW_SIZE)
		btn.text = d.text
		btn.name = "Arrow" + d.name
		btn.pressed.connect(_on_arrow_pressed.bind(d.dir))
		arrow_buttons.append(btn)
		add_child(btn)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		_cancel()

func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_cancel()

func show_for_unit(map: Node2D, grid_pos: Vector2i) -> void:
	map_node = map
	unit_grid_pos = grid_pos
	if not map_node:
		return
	if back_panel == null or arrow_buttons.is_empty():
		_setup_ui()
	back_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	back_panel.offset_left = 0
	back_panel.offset_top = 0
	back_panel.offset_right = 0
	back_panel.offset_bottom = 0
	var base_global = map_node.global_position
	var dirs = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	for i in range(4):
		var tile = grid_pos + dirs[i]
		var local_center = Vector2(tile.x * TILE_SIZE + TILE_SIZE / 2.0, tile.y * TILE_SIZE + TILE_SIZE / 2.0)
		var screen_pos = base_global + local_center
		arrow_buttons[i].position = screen_pos - Vector2(ARROW_SIZE / 2, ARROW_SIZE / 2)
		arrow_buttons[i].z_index = 10
	visible = true
	back_panel.z_index = 0
	GameState.direction_select_active = true

func hide_overlay() -> void:
	visible = false
	map_node = null
	GameState.direction_select_active = false

func _on_arrow_pressed(dir: Vector2i) -> void:
	if map_node and map_node.has_method("execute_q_direction"):
		map_node.execute_q_direction(dir)
	hide_overlay()

func _cancel() -> void:
	if map_node and map_node.has_method("cancel_skill_mode"):
		map_node.cancel_skill_mode()
	hide_overlay()
