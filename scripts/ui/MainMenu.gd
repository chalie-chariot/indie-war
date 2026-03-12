extends Control
## MainMenu - 메뉴 6개, 마스터 Tween 동기화 (0.4초)

const RIGHT_AREA_LEFT: int = 400

var menus: Array[Dictionary] = [
	{"name": "계승전", "desc": "세력 전투"},
	{"name": "캐릭터 정보", "desc": "캐릭터 상세 설명 창 화면"},
	{"name": "세계관 개요", "desc": "세력 / 세계관에 대한 상세 설명"},
	{"name": "계승의 서", "desc": "최근 계승전 전투 승/패 기록"},
	{"name": "기록 보관소", "desc": "영상연출 / BGM 등 전투 외의 공간"},
	{"name": "성역", "desc": "원하는 캐릭터의 빌드로 연습 모드"}
]
var current_index: int = 0
var is_animating: bool = false

@onready var logo_label: Label = $RightArea/TitleArea/LogoRow/LogoWrapper/LogoContainer/LogoLabel
@onready var title_label: Label = $RightArea/TitleArea/TitleRowWrapper/TitleRow/TitleBlock/TitleLabel
@onready var menu_underline: Control = $RightArea/TitleArea/TitleRowWrapper/TitleRow/TitleBlock/UnderLine
@onready var prev_btn: Control = $RightArea/TitleArea/TitleRowWrapper/TitleRow/PrevBtn
@onready var next_btn: Control = $RightArea/TitleArea/TitleRowWrapper/TitleRow/NextBtn
@onready var hint_box: Control = $HintBox
@onready var indicator_dots: Control = $RightArea/IndicatorDots
@onready var eclipse_circle: Control = $RightArea/EclipseCircle
@onready var left_white_circle: Control = $RightArea/TitleArea/TitleRowWrapper/LeftWhiteCircle
@onready var right_white_circle: Control = $RightArea/TitleArea/TitleRowWrapper/RightWhiteCircle

func _ready() -> void:
	_apply_fonts()
	prev_btn.pressed.connect(func() -> void: _change_menu(-1))
	next_btn.pressed.connect(func() -> void: _change_menu(1))
	prev_btn.modulate = Color(1, 1, 1, 0.4)
	next_btn.modulate = Color(1, 1, 1, 0.4)
	prev_btn.mouse_entered.connect(_on_nav_hover.bind(prev_btn))
	prev_btn.mouse_exited.connect(_on_nav_unhover.bind(prev_btn))
	next_btn.mouse_entered.connect(_on_nav_hover.bind(next_btn))
	next_btn.mouse_exited.connect(_on_nav_unhover.bind(next_btn))
	_update_ui_immediate()
	_play_hint_animation()

func _input(event: InputEvent) -> void:
	if is_animating:
		return
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			var pos: Vector2 = get_global_mouse_position()
			if left_white_circle and left_white_circle.get_global_rect().has_point(pos):
				accept_event()
				_change_menu(-1)
				return
			if right_white_circle and right_white_circle.get_global_rect().has_point(pos):
				accept_event()
				_change_menu(1)
				return
			if title_label and title_label.get_global_rect().has_point(pos):
				accept_event()
				_execute_current_menu()
				return
	if event is InputEventKey:
		var ke: InputEventKey = event as InputEventKey
		if ke.pressed and not ke.echo:
			if ke.keycode == KEY_ENTER or ke.keycode == KEY_KP_ENTER or ke.keycode == KEY_SPACE:
				_execute_current_menu()
			elif ke.keycode == KEY_ESCAPE:
				get_tree().quit()
			elif ke.keycode == KEY_LEFT or ke.keycode == KEY_A:
				_change_menu(-1)
			elif ke.keycode == KEY_RIGHT or ke.keycode == KEY_D:
				_change_menu(1)

func _apply_fonts() -> void:
	var black_han: Font = _load_font("res://assets/fonts/BlackHanSans-Regular.ttf")
	var noto: Font = _load_font("res://assets/fonts/NotoSansKR-Regular.otf")
	if noto == null:
		noto = _load_font("res://assets/fonts/NotoSansKR-Regular.ttf")
	if is_instance_valid(title_label) and black_han:
		title_label.add_theme_font_override("font", black_han)
	if hint_box and noto:
		for c in hint_box.get_children():
			if c is Label:
				c.add_theme_font_override("font", noto)
				c.add_theme_font_size_override("font_size", 16)

func _load_font(path: String) -> Font:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Font

func _play_hint_animation() -> void:
	if not hint_box:
		return
	await get_tree().create_timer(1.0).timeout
	var t := create_tween()
	t.tween_property(hint_box, "modulate", Color(1, 1, 1, 1), 0.6).from(Color(1, 1, 1, 0))
	await get_tree().create_timer(3.5).timeout
	var t2 := create_tween()
	t2.tween_property(hint_box, "modulate", Color(1, 1, 1, 0), 1.0)

func _pulse_menu_label() -> void:
	if not title_label:
		return
	title_label.pivot_offset = title_label.size * 0.5
	var pulse := create_tween()
	pulse.tween_property(title_label, "scale", Vector2(1.08, 1.08), 0.08)
	pulse.tween_property(title_label, "scale", Vector2(1.0, 1.0), 0.12)

func _on_nav_hover(btn: Control) -> void:
	var tw := create_tween()
	tw.tween_property(btn, "modulate", Color(1, 1, 1, 1), 0.15)

func _on_nav_unhover(btn: Control) -> void:
	var tw := create_tween()
	tw.tween_property(btn, "modulate", Color(1, 1, 1, 0.4), 0.15)

func _change_menu(direction: int) -> void:
	if is_animating:
		return
	is_animating = true
	_pulse_menu_label()

	# 인덱스·텍스트·도트 즉시 변경
	_apply_index_change(direction)
	if menu_underline:
		menu_underline.call_deferred("queue_redraw")

	var tween := create_tween()
	tween.set_parallel(false)
	tween.tween_callback(_play_diamond_anim.bind(direction))
	tween.tween_interval(0.40)
	tween.tween_callback(func() -> void: is_animating = false)

func _play_diamond_anim(direction: int) -> void:
	if eclipse_circle and eclipse_circle.has_method("play_diamond_anim"):
		eclipse_circle.play_diamond_anim(direction)

func _apply_index_change(direction: int) -> void:
	if direction > 0:
		current_index += 1
		if current_index >= 6:
			current_index = 0
	else:
		current_index -= 1
		if current_index < 0:
			current_index = 5
	_update_ui_immediate()
	if indicator_dots and indicator_dots.has_method("set_active_index"):
		indicator_dots.set_active_index(current_index, direction > 0)

func _update_ui_immediate() -> void:
	if title_label and current_index >= 0 and current_index < menus.size():
		title_label.text = menus[current_index].name
	_update_logo_placeholder(current_index + 1)

func _execute_current_menu() -> void:
	match current_index:
		0:
			get_tree().change_scene_to_file("res://scenes/game/GameManager.tscn")
		1:
			get_tree().change_scene_to_file("res://scenes/ui/CharacterSelect.tscn")
		2:
			print("세계관 개요 미구현")
		3:
			print("계승의 서 미구현")
		4:
			print("기록 보관소 미구현")
		5:
			print("성역 미구현")

func _update_logo_placeholder(menu_num: int) -> void:
	if logo_label:
		logo_label.text = str(menu_num)
