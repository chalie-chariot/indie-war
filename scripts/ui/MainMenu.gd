extends Control
## MainMenu - 메뉴 6개, 이름/설명 표시, 인디케이터 원형 배치

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

@onready var logo_placeholder: ColorRect = $RightArea/TitleArea/LogoRow/LogoWrapper/LogoPlaceholder
@onready var title_label: Label = $RightArea/TitleArea/TitleRowWrapper/TitleRow/TitleLabel
@onready var prev_btn: Control = $RightArea/TitleArea/TitleRowWrapper/TitleRow/PrevBtn
@onready var next_btn: Control = $RightArea/TitleArea/TitleRowWrapper/TitleRow/NextBtn
@onready var indicator_dots: Control = $RightArea/IndicatorDots
@onready var eclipse_circle: Control = $RightArea/EclipseCircle
@onready var divider_glow: Control = $RightArea/TitleArea/TitleRowWrapper
@onready var left_white_circle: Control = $RightArea/TitleArea/TitleRowWrapper/LeftWhiteCircle
@onready var right_white_circle: Control = $RightArea/TitleArea/TitleRowWrapper/RightWhiteCircle

func _ready() -> void:
	_apply_fonts()
	prev_btn.pressed.connect(_on_prev_pressed)
	next_btn.pressed.connect(_on_next_pressed)
	_update_ui()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			var pos: Vector2 = get_global_mouse_position()
			if left_white_circle and left_white_circle.get_global_rect().has_point(pos):
				accept_event()
				_on_prev_pressed()
				return
			if right_white_circle and right_white_circle.get_global_rect().has_point(pos):
				accept_event()
				_on_next_pressed()
				return
	if event is InputEventKey:
		var ke: InputEventKey = event as InputEventKey
		if ke.pressed and not ke.echo:
			if ke.keycode == KEY_ENTER or ke.keycode == KEY_KP_ENTER or ke.keycode == KEY_SPACE:
				_execute_current_menu()
			elif ke.keycode == KEY_LEFT or ke.keycode == KEY_A:
				_on_prev_pressed()
			elif ke.keycode == KEY_RIGHT or ke.keycode == KEY_D:
				_on_next_pressed()

func _apply_fonts() -> void:
	var black_han: Font = _load_font("res://assets/fonts/BlackHanSans-Regular.ttf")
	if is_instance_valid(title_label) and black_han:
		title_label.add_theme_font_override("font", black_han)

func _load_font(path: String) -> Font:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Font

func _on_prev_pressed() -> void:
	current_index -= 1
	if current_index < 0:
		current_index = 5
	if divider_glow and divider_glow.has_method("animate_right_to_left"):
		divider_glow.animate_right_to_left()
	if indicator_dots and indicator_dots.has_method("set_active_index"):
		indicator_dots.set_active_index(current_index, false)
	if eclipse_circle and eclipse_circle.has_method("set_active_index"):
		eclipse_circle.set_active_index(current_index)

func _on_next_pressed() -> void:
	current_index += 1
	if current_index >= 6:
		current_index = 0
	if divider_glow and divider_glow.has_method("animate_left_to_right"):
		divider_glow.animate_left_to_right()
	if indicator_dots and indicator_dots.has_method("set_active_index"):
		indicator_dots.set_active_index(current_index, true)
	if eclipse_circle and eclipse_circle.has_method("set_active_index"):
		eclipse_circle.set_active_index(current_index)

func _update_ui() -> void:
	_update_logo_placeholder(current_index + 1)
	if indicator_dots and indicator_dots.has_method("set_active_index"):
		indicator_dots.set_active_index(current_index, true)
	if eclipse_circle and eclipse_circle.has_method("set_active_index"):
		eclipse_circle.set_active_index(current_index)

func _execute_current_menu() -> void:
	match current_index:
		0:
			get_tree().change_scene_to_file("res://scenes/game/GameManager.tscn")
		1:
			print("캐릭터 정보 미구현")
		2:
			print("세계관 개요 미구현")
		3:
			print("계승의 서 미구현")
		4:
			print("기록 보관소 미구현")
		5:
			print("성역 미구현")

func _update_logo_placeholder(menu_num: int) -> void:
	if not logo_placeholder:
		return
	var existing: Node = logo_placeholder.get_node_or_null("MenuNumLabel")
	if existing:
		existing.queue_free()
	var label: Label = Label.new()
	label.name = "MenuNumLabel"
	label.text = str(menu_num)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color.BLACK)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(64, 64)
	logo_placeholder.add_child(label)
