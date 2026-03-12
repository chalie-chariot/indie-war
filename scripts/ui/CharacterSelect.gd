extends Control
## 캐릭터 선택창 - 슬롯 60개 (10x6), 페이지당 20개 (10x2)

var characters: Array[Dictionary] = [
	{"id": "A", "name": "선인 (仙人)", "color": Color(0.9, 0.9, 0.9, 1)},
	{"id": "B", "name": "무사 (武士)", "color": Color(0.8, 0.8, 0.8, 1)},
	{"id": "C", "name": "음양사", "color": Color(0.85, 0.85, 0.85, 1)},
	{"id": "D", "name": "팔라딘", "color": Color(0.75, 0.75, 0.75, 1)},
	{"id": "E", "name": "궁수", "color": Color(0.7, 0.7, 0.7, 1)},
	{"id": "F", "name": "???", "color": Color(0.3, 0.3, 0.3, 1)},
]
var selected_index: int = 0
var _user_has_picked: bool = false

const CARD_NAMES: PackedStringArray = ["A", "B", "C", "D", "E", "F"]

# 더미 아이콘: 선인/무사→솔페란, 음양사→디스마리스, 궁수/팔라딘→엘노르
const CHAR_ICONS: Array[Texture2D] = [
	preload("res://assets/img/솔페란.png"),   # 0 선인
	preload("res://assets/img/솔페란.png"),   # 1 무사
	preload("res://assets/img/디스마리스.png"), # 2 음양사
	preload("res://assets/img/엘노르.png"),   # 3 팔라딘
	preload("res://assets/img/엘노르.png"),   # 4 궁수
]
# 세력별 발광 색상: 솔페란=붉은핑크, 디스마리스=보라, 엘노르=청록
const CHAR_GLOW_COLORS: Array[Color] = [
	Color(1.0, 0.02, 0.04),   # 더 새빨간색 솔페란
	Color(1.0, 0.02, 0.04),   # 솔페란
	Color(0.608, 0.188, 1.0),  # #9B30FF 디스마리스
	Color(0.0, 1.0, 0.8),   # #00FFCC 엘노르
	Color(0.0, 1.0, 0.8),   # 엘노르
]

@onready var char_sprite: ColorRect = $CharacterDisplay/CharSprite
@onready var char_name_label: Label = $CharacterDisplay/CharNameLabel
@onready var char_icon_dummy: TextureRect = $CharIconDummy
@onready var detail_button: Control = $DetailButton
@onready var scroll_container: ScrollContainer = $CardStrip/ScrollContainer
@onready var card_grid: VBoxContainer = $CardStrip/ScrollContainer/GridWrap/CardGrid
@onready var page_dots: Control = $PageDots
@onready var left_bar: ColorRect = $CardStrip/LeftBar
@onready var right_bar: ColorRect = $CardStrip/RightBar

const SLOTS_TOTAL: int = 60
const COLS: int = 10
const ROWS: int = 6
const SLOTS_PER_PAGE: int = 20  # 10x2
const ROWS_PER_PAGE: int = 2
const CARD_WIDTH: int = 80
const CARD_HEIGHT: int = 120
const CARD_SEP: int = 8
const ROW_HEIGHT: int = CARD_HEIGHT + CARD_SEP
var page_index: int = 0
var _max_page: int = 2  # 3 pages (0,1,2)

const CARD_PIVOT: Vector2 = Vector2(40, 60)
const CARD_SCALE_SELECTED: float = 1.0
const CARD_SCALE_NORMAL: float = 0.7
const CARD_TWEEN_DURATION: float = 0.06

var _name_wrapper: Control = null
var _name_tween: Tween = null

func _ready() -> void:
	_apply_fonts()
	_setup_name_wrapper()
	_setup_char_icon_dummy()
	_setup_scroll_container()
	_setup_edge_bars()
	_setup_cards()
	if detail_button:
		detail_button.gui_input.connect(_on_detail_button_gui_input)
	if page_dots:
		page_dots.page_count = 3
	call_deferred("_update_detail_button_position")
	call_deferred("_update_char_icon_position")
	call_deferred("_scroll_to_page", 0)
	call_deferred("_update_edge_bars")
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
		accept_event()
		return
	if event.is_action_pressed("ui_left"):
		var next_idx: int
		if selected_index % COLS > 0:
			next_idx = selected_index - 1
		else:
			next_idx = (selected_index - 1 + SLOTS_TOTAL) % SLOTS_TOTAL
		_select_card(next_idx)
		accept_event()
		return
	if event.is_action_pressed("ui_right"):
		var next_idx: int = (selected_index + 1) % SLOTS_TOTAL
		_select_card(next_idx)
		accept_event()
		return
	if event.is_action_pressed("ui_up"):
		var next_idx: int
		if selected_index >= COLS:
			next_idx = selected_index - COLS
		else:
			next_idx = (selected_index - COLS + SLOTS_TOTAL) % SLOTS_TOTAL
		_select_card(next_idx)
		accept_event()
		return
	if event.is_action_pressed("ui_down"):
		var next_idx: int = (selected_index + COLS) % SLOTS_TOTAL
		_select_card(next_idx)
		accept_event()
		return

func _apply_fonts() -> void:
	var black_han: Font = _load_font("res://assets/fonts/BlackHanSans-Regular.ttf")
	if black_han and char_name_label:
		char_name_label.add_theme_font_override("font", black_han)
	var noto: Font = _load_font("res://assets/fonts/NotoSansKR-Regular.otf")
	if noto and detail_button:
		var dl: Node = detail_button.get_node_or_null("DetailLabel")
		if dl:
			dl.add_theme_font_override("font", noto)

func _on_viewport_size_changed() -> void:
	_update_detail_button_position()
	_update_char_icon_position()

func _update_detail_button_position() -> void:
	if not char_sprite or not detail_button:
		return
	var char_display: Control = char_sprite.get_parent() as Control
	if not char_display:
		return
	# 캐릭터 화면 우측 끝 + 여백, 캐릭터와 겹치지 않게
	const GAP: float = 24.0
	var right_edge: float = char_display.global_position.x + char_display.size.x
	detail_button.global_position = Vector2(right_edge + GAP, char_sprite.global_position.y - 18)
	detail_button.scale = Vector2(1.5, 1.5)  # 마름모·텍스트 함께 1.5배

func _setup_char_icon_dummy() -> void:
	if char_icon_dummy:
		var shader: Shader = load("res://assets/shaders/icon_glow.gdshader") as Shader
		if shader:
			char_icon_dummy.material = ShaderMaterial.new()
			char_icon_dummy.material.shader = shader
	_update_char_icon()

func _update_char_icon_position() -> void:
	if not char_icon_dummy:
		return
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	var icon_w: float = 240.0
	var icon_h: float = 200.0
	var margin: float = 24.0
	char_icon_dummy.offset_left = vp_size.x - icon_w - margin
	char_icon_dummy.offset_top = margin
	char_icon_dummy.offset_right = vp_size.x - margin
	char_icon_dummy.offset_bottom = margin + icon_h
	char_icon_dummy.custom_minimum_size = Vector2(icon_w, icon_h)

func _update_char_icon() -> void:
	if not char_icon_dummy:
		return
	if selected_index < CHAR_ICONS.size():
		char_icon_dummy.texture = CHAR_ICONS[selected_index]
		char_icon_dummy.visible = true
		# 세력별 발광 색상 적용
		var mat: ShaderMaterial = char_icon_dummy.material as ShaderMaterial
		if mat and selected_index < CHAR_GLOW_COLORS.size():
			mat.set_shader_parameter("glow_color", CHAR_GLOW_COLORS[selected_index])
	else:
		char_icon_dummy.visible = false

func _setup_scroll_container() -> void:
	var panel_style := StyleBoxEmpty.new()
	scroll_container.add_theme_stylebox_override("panel", panel_style)

const BAR_COLOR_GRAY: Color = Color(0, 0, 0, 1)
const BAR_COLOR_GLOW: Color = Color(0.95, 0.9, 0.3, 1.0)
const BAR_GLOW_SPREAD_DURATION: float = 0.25
const BAR_GLOW_HOLD_DURATION: float = 0.2
const BAR_GLOW_FADE_DURATION: float = 0.5
var _left_bar_mat: ShaderMaterial
var _right_bar_mat: ShaderMaterial
var _left_glow_tween: Tween
var _right_glow_tween: Tween
var _left_was_glow: bool = false
var _right_was_glow: bool = false
var _left_sustain_particles: GPUParticles2D
var _right_sustain_particles: GPUParticles2D

func _create_bar_sustain_particles(parent: Control) -> GPUParticles2D:
	var bar_w: float = parent.custom_minimum_size.x
	var bar_h: float = parent.custom_minimum_size.y
	var particles := GPUParticles2D.new()
	particles.one_shot = false
	particles.amount = 24
	particles.lifetime = 1.4
	particles.emitting = false
	particles.position = Vector2(bar_w / 2.0, bar_h / 2.0)
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 165.0
	mat.initial_velocity_min = 50.0
	mat.initial_velocity_max = 110.0
	mat.gravity = Vector3.ZERO
	mat.damping_min = 8.0
	mat.damping_max = 18.0
	mat.scale_min = 0.15
	mat.scale_max = 0.35
	mat.color = Color(0.98, 0.95, 0.5, 0.55)
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(bar_w / 2.0, bar_h / 2.0, 1.0)
	var scale_curve := Curve.new()
	scale_curve.add_point(Vector2(0, 0.85))
	scale_curve.add_point(Vector2(0.25, 1.0))
	scale_curve.add_point(Vector2(0.6, 0.4))
	scale_curve.add_point(Vector2(0.85, 0.08))
	scale_curve.add_point(Vector2(1, 0))
	var scale_tex := CurveTexture.new()
	scale_tex.curve = scale_curve
	mat.scale_curve = scale_tex
	var alpha_curve := Curve.new()
	alpha_curve.add_point(Vector2(0, 0.35))
	alpha_curve.add_point(Vector2(0.2, 0.6))
	alpha_curve.add_point(Vector2(0.5, 0.4))
	alpha_curve.add_point(Vector2(0.8, 0.1))
	alpha_curve.add_point(Vector2(1, 0))
	var alpha_tex := CurveTexture.new()
	alpha_tex.curve = alpha_curve
	mat.alpha_curve = alpha_tex
	var color_grad := Gradient.new()
	color_grad.add_point(0.0, Color(1.0, 0.98, 0.6, 1.0))
	color_grad.add_point(0.5, Color(0.98, 0.92, 0.45, 1.0))
	color_grad.add_point(1.0, Color(0.95, 0.88, 0.35, 0.0))
	var color_ramp_tex := GradientTexture1D.new()
	color_ramp_tex.gradient = color_grad
	mat.color_ramp = color_ramp_tex
	particles.process_material = mat
	var tex2: Texture2D = load("res://assets/textures/particle_glow_soft.tres") as Texture2D
	if not tex2:
		tex2 = load("res://assets/textures/light_circle_gradient.tres") as Texture2D
	if tex2:
		particles.texture = tex2
	var part_mat := CanvasItemMaterial.new()
	part_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	particles.material = part_mat
	parent.add_child(particles)
	return particles

func _setup_edge_bars() -> void:
	var bar_shader: Shader = load("res://assets/shaders/bar_glow.gdshader") as Shader
	if bar_shader:
		if left_bar:
			_left_bar_mat = ShaderMaterial.new()
			_left_bar_mat.shader = bar_shader
			_left_bar_mat.set_shader_parameter("color_gray", BAR_COLOR_GRAY)
			_left_bar_mat.set_shader_parameter("color_glow", BAR_COLOR_GLOW)
			_left_bar_mat.set_shader_parameter("spread", 0.0)
			_left_bar_mat.set_shader_parameter("intensity", 0.0)
			left_bar.material = _left_bar_mat
			left_bar.mouse_filter = Control.MOUSE_FILTER_STOP
			left_bar.gui_input.connect(_on_left_bar_gui_input)
			_left_sustain_particles = _create_bar_sustain_particles(left_bar)
		if right_bar:
			_right_bar_mat = ShaderMaterial.new()
			_right_bar_mat.shader = bar_shader
			_right_bar_mat.set_shader_parameter("color_gray", BAR_COLOR_GRAY)
			_right_bar_mat.set_shader_parameter("color_glow", BAR_COLOR_GLOW)
			_right_bar_mat.set_shader_parameter("spread", 0.0)
			_right_bar_mat.set_shader_parameter("intensity", 0.0)
			right_bar.material = _right_bar_mat
			right_bar.mouse_filter = Control.MOUSE_FILTER_STOP
			right_bar.gui_input.connect(_on_right_bar_gui_input)
			_right_sustain_particles = _create_bar_sustain_particles(right_bar)
	else:
		if left_bar:
			left_bar.mouse_filter = Control.MOUSE_FILTER_STOP
			left_bar.gui_input.connect(_on_left_bar_gui_input)
		if right_bar:
			right_bar.mouse_filter = Control.MOUSE_FILTER_STOP
			right_bar.gui_input.connect(_on_right_bar_gui_input)

func _update_bar_glow(bar_mat: ShaderMaterial, should_glow: bool, tween_ref: String) -> void:
	if not bar_mat:
		return
	if tween_ref == "left" and _left_glow_tween:
		_left_glow_tween.kill()
	elif tween_ref == "right" and _right_glow_tween:
		_right_glow_tween.kill()
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	if tween_ref == "left":
		_left_glow_tween = tween
	else:
		_right_glow_tween = tween
	if should_glow:
		if tween_ref == "left" and _left_sustain_particles:
			_left_sustain_particles.emitting = true
		elif tween_ref == "right" and _right_sustain_particles:
			_right_sustain_particles.emitting = true
		bar_mat.set_shader_parameter("spread", 0.0)
		bar_mat.set_shader_parameter("intensity", 0.0)
		tween.tween_method(func(v): bar_mat.set_shader_parameter("spread", v), 0.0, 1.0, BAR_GLOW_SPREAD_DURATION * 0.5)
		tween.parallel().tween_method(func(v): bar_mat.set_shader_parameter("intensity", v), 0.0, 1.0, BAR_GLOW_SPREAD_DURATION)
	else:
		if tween_ref == "left" and _left_sustain_particles:
			_left_sustain_particles.emitting = false
		elif tween_ref == "right" and _right_sustain_particles:
			_right_sustain_particles.emitting = false
		tween.tween_interval(BAR_GLOW_HOLD_DURATION)
		tween.tween_method(func(v): bar_mat.set_shader_parameter("intensity", v), 1.0, 0.0, BAR_GLOW_FADE_DURATION)

func _update_edge_bars() -> void:
	var at_left_end: bool = _user_has_picked and (selected_index % COLS == 0)
	var at_right_end: bool = _user_has_picked and (selected_index % COLS == COLS - 1)
	if left_bar:
		var left_visible: bool = (page_index == 0)
		if not left_visible:
			_left_was_glow = false
		left_bar.visible = left_visible
		if left_bar.visible and _left_bar_mat:
			if _left_was_glow != at_left_end:
				_left_was_glow = at_left_end
				_update_bar_glow(_left_bar_mat, at_left_end, "left")
		elif left_bar.visible and not _left_bar_mat:
			left_bar.color = BAR_COLOR_GLOW if at_left_end else BAR_COLOR_GRAY
	if right_bar:
		var right_visible: bool = (page_index == _max_page)
		if not right_visible:
			_right_was_glow = false
		right_bar.visible = right_visible
		if right_bar.visible and _right_bar_mat:
			if _right_was_glow != at_right_end:
				_right_was_glow = at_right_end
				_update_bar_glow(_right_bar_mat, at_right_end, "right")
		elif right_bar.visible and not _right_bar_mat:
			right_bar.color = BAR_COLOR_GLOW if at_right_end else BAR_COLOR_GRAY

func _on_left_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			if page_index > 0:
				_scroll_to_page(page_index - 1)
				accept_event()

func _on_right_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			if page_index < _max_page:
				_scroll_to_page(page_index + 1)
				accept_event()

func _setup_name_wrapper() -> void:
	var label: Label = char_name_label
	if not label:
		return
	var parent: Control = label.get_parent() as Control
	if not parent:
		return
	_name_wrapper = Control.new()
	_name_wrapper.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_name_wrapper.offset_left = 40
	_name_wrapper.offset_top = 400
	_name_wrapper.offset_right = 280
	_name_wrapper.offset_bottom = 436
	_name_wrapper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.remove_child(label)
	_name_wrapper.add_child(label)
	parent.add_child(_name_wrapper)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 0
	label.offset_top = 0
	label.offset_right = 0
	label.offset_bottom = 0

func _load_font(path: String) -> Font:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Font

func _create_card_style(white: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 1) if white else Color(0.2, 0.2, 0.2, 1)
	style.set_corner_radius_all(8)
	return style

func _get_card_at(index: int) -> Control:
	if index < 0 or index >= SLOTS_TOTAL:
		return null
	var row_idx: int = index / COLS
	var col_idx: int = index % COLS
	var row: HBoxContainer = card_grid.get_child(row_idx) as HBoxContainer
	if not row:
		return null
	return row.get_child(col_idx) as Control

func _setup_cards() -> void:
	var row_width: int = COLS * CARD_WIDTH + (COLS - 1) * CARD_SEP
	card_grid.custom_minimum_size.x = row_width
	card_grid.custom_minimum_size.y = ROWS * ROW_HEIGHT
	card_grid.add_theme_constant_override("separation", 0)
	for row_idx in ROWS:
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(row_width, ROW_HEIGHT)
		row.add_theme_constant_override("separation", CARD_SEP)
		for col_idx in COLS:
			var index: int = row_idx * COLS + col_idx
			var card := VBoxContainer.new()
			card.custom_minimum_size = Vector2(CARD_WIDTH, CARD_HEIGHT)
			card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			card.mouse_filter = Control.MOUSE_FILTER_STOP
			card.gui_input.connect(_on_card_gui_input.bind(index))
			var rect := Panel.new()
			rect.custom_minimum_size = Vector2(CARD_WIDTH, CARD_HEIGHT - 14)
			rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var is_char: bool = index < characters.size()
			rect.add_theme_stylebox_override("panel", _create_card_style(index < 5))
			var label := Label.new()
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.add_theme_font_size_override("font_size", 14)
			label.text = CARD_NAMES[index] if index < 6 else "-"
			if index >= 6:
				label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
			else:
				label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
			card.add_child(rect)
			card.add_child(label)
			rect.name = "CardRect"
			label.name = "CardLabel"
			row.add_child(card)
		card_grid.add_child(row)
	_update_display()

const NAME_SLIDE_OFFSET: float = 80.0
const NAME_FADE_DURATION: float = 0.35

func _update_display() -> void:
	var ch: Dictionary
	if selected_index < characters.size():
		ch = characters[selected_index]
	else:
		ch = {"name": "???", "color": Color(0.2, 0.2, 0.2, 1)}
	char_sprite.color = ch.get("color", Color(0.2, 0.2, 0.2, 1))
	char_name_label.text = ch.get("name", "???")
	_update_char_icon()
	var name_text: String = ch.get("name", "???")
	if name_text != "???":
		_animate_name_in()
	else:
		if _name_wrapper:
			_name_wrapper.modulate = Color(1, 1, 1, 1)
		if char_name_label:
			char_name_label.position = Vector2.ZERO
	_update_card_glow()

func _animate_name_in() -> void:
	if not _name_wrapper or not char_name_label:
		return
	if _name_tween:
		_name_tween.kill()
	# 래퍼는 고정, 라벨만 내부에서 오른쪽→왼쪽 슬라이드
	char_name_label.position = Vector2(NAME_SLIDE_OFFSET, 0)
	_name_wrapper.modulate = Color(1, 1, 1, 0)
	_name_tween = create_tween()
	_name_tween.set_ease(Tween.EASE_OUT)
	_name_tween.set_trans(Tween.TRANS_CUBIC)
	_name_tween.tween_property(char_name_label, "position", Vector2.ZERO, NAME_FADE_DURATION)
	_name_tween.parallel().tween_property(_name_wrapper, "modulate", Color(1, 1, 1, 1), NAME_FADE_DURATION)

func _update_card_glow() -> void:
	for i in SLOTS_TOTAL:
		var card: Control = _get_card_at(i)
		if not card:
			continue
		var is_selected: bool = (i == selected_index)
		var target_scale: float = CARD_SCALE_SELECTED if is_selected else CARD_SCALE_NORMAL
		card.pivot_offset = CARD_PIVOT
		var rect: Panel = card.get_node_or_null("CardRect") as Panel
		if rect:
			rect.modulate = Color(1.05, 1.05, 1.05, 1) if is_selected else Color(1, 1, 1, 1)
		var tween := create_tween()
		tween.tween_property(card, "scale", Vector2(target_scale, target_scale), CARD_TWEEN_DURATION).set_ease(Tween.EASE_OUT)

func _on_card_gui_input(event: InputEvent, index: int) -> void:
	if not event is InputEventMouseButton:
		return
	var mb: InputEventMouseButton = event as InputEventMouseButton
	if mb.button_index != MOUSE_BUTTON_LEFT or not mb.pressed:
		return
	_select_card(index)

func _select_card(index: int) -> void:
	if selected_index == index:
		return
	if index < 0 or index >= SLOTS_TOTAL:
		return
	_user_has_picked = true
	selected_index = index
	var ch: Dictionary
	if index < characters.size():
		ch = characters[index]
	else:
		ch = {"name": "???", "color": Color(0.2, 0.2, 0.2, 1)}
	char_sprite.color = ch.get("color", Color(0.2, 0.2, 0.2, 1))
	char_name_label.text = ch.get("name", "???")
	_update_char_icon()
	var name_text: String = ch.get("name", "???")
	if name_text != "???":
		_animate_name_in()
	else:
		if _name_wrapper:
			_name_wrapper.modulate = Color(1, 1, 1, 1)
		if char_name_label:
			char_name_label.position = Vector2.ZERO
	var target_page: int = selected_index / SLOTS_PER_PAGE
	if target_page != page_index:
		_scroll_to_page(target_page)
	_update_card_glow()
	_update_edge_bars()

func _on_detail_button_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var mb: InputEventMouseButton = event as InputEventMouseButton
	if mb.button_index != MOUSE_BUTTON_LEFT or not mb.pressed:
		return
	_on_detail_click()

func _on_detail_click() -> void:
	GameState.selected_character_index = selected_index
	get_tree().change_scene_to_file("res://scenes/ui/CharacterInfo.tscn")

func _scroll_to_page(p: int) -> void:
	page_index = clampi(p, 0, _max_page)
	var target_scroll: int = page_index * ROWS_PER_PAGE * ROW_HEIGHT
	scroll_container.scroll_vertical = target_scroll
	if page_dots.has_method("set_page"):
		page_dots.set_page(page_index)
	else:
		page_dots.set("active_index", page_index)
		page_dots.queue_redraw()
	_update_edge_bars()
