extends Control
## MainMenu - 메인 메뉴 UI (좌우 화살표 + 인디케이터 도트)

const RIGHT_AREA_LEFT: int = 400

var menus: Array[String] = [
	"게임 시작",
	"신 선택",
	"스테이지 선택",
	"용병 도감",
	"설정",
	"종료"
]
var current_index: int = 0

@onready var logo_placeholder: ColorRect = $RightArea/TitleArea/LogoRow/LogoWrapper/LogoPlaceholder
@onready var title_label: Label = $RightArea/TitleArea/TitleRowWrapper/TitleRow/TitleLabel
@onready var prev_btn: Control = $RightArea/TitleArea/TitleRowWrapper/TitleRow/PrevBtn
@onready var next_btn: Control = $RightArea/TitleArea/TitleRowWrapper/TitleRow/NextBtn
@onready var indicator_dots: Control = $RightArea/IndicatorDots
@onready var eclipse_circle: Control = $RightArea/EclipseCircle
@onready var divider_glow: Control = $RightArea/TitleArea/TitleRowWrapper

func _ready() -> void:
	_apply_fonts()
	prev_btn.pressed.connect(_on_prev_pressed)
	next_btn.pressed.connect(_on_next_pressed)
	_update_ui()
	if indicator_dots and indicator_dots.has_method("set_active_index"):
		indicator_dots.set_active_index(current_index)
	if eclipse_circle and eclipse_circle.has_method("set_active_index"):
		eclipse_circle.set_active_index(current_index)

func _input(event: InputEvent) -> void:
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
	if black_han:
		for node in [title_label]:
			if is_instance_valid(node):
				node.add_theme_font_override("font", black_han)

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
	_update_ui()

func _on_next_pressed() -> void:
	current_index += 1
	if current_index >= 6:
		current_index = 0
	if divider_glow and divider_glow.has_method("animate_left_to_right"):
		divider_glow.animate_left_to_right()
	_update_ui()

func _update_ui() -> void:
	_update_logo_placeholder(current_index + 1)
	if indicator_dots and indicator_dots.has_method("set_active_index"):
		indicator_dots.set_active_index(current_index)
	if eclipse_circle and eclipse_circle.has_method("set_active_index"):
		eclipse_circle.set_active_index(current_index)

func _execute_current_menu() -> void:
	match current_index:
		0:
			get_tree().change_scene_to_file("res://scenes/game/GameManager.tscn")
		1:
			print("신 선택 미구현")
		2:
			print("스테이지 선택 미구현")
		3:
			print("용병 도감 미구현")
		4:
			print("설정 미구현")
		5:
			get_tree().quit()

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
