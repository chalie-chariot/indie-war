extends Control
## MainMenu - 메인 메뉴 UI (참고 이미지 스펙)

# 좌측 0~400 캐릭터 영역, 우측 400~ 반원 영역
# 원 중심: 화면 X 1300, Y 1180 | 지름 1200
const CIRCLE_CENTER_X := 1300.0
const RIGHT_AREA_LEFT := 400

# 버튼: 화면 절대좌표 (중심점) - 반원 호 안쪽, Y 1080 이내
const BUTTON_CENTERS_SCREEN: Array[Vector2] = [
	Vector2(1300, 430),   # 1: 반원 최상단 중앙
	Vector2(1100, 530),   # 2: 좌측 상단
	Vector2(1500, 530),   # 3: 우측 상단
	Vector2(1050, 680),   # 4: 좌측 하단
	Vector2(1550, 680),   # 5: 우측 하단
	Vector2(1300, 750)    # 6: 중앙 하단
]
const BUTTON_SIZE := 36

@onready var logo_placeholder: ColorRect = $RightArea/TitleArea/LogoRow/LogoWrapper/LogoPlaceholder
@onready var title_label: Label = $RightArea/TitleArea/TitleLabel
@onready var menu_buttons: Control = $RightArea/MenuButtons
@onready var btn_list: Array[Control] = [
	$RightArea/MenuButtons/Btn1,
	$RightArea/MenuButtons/Btn2,
	$RightArea/MenuButtons/Btn3,
	$RightArea/MenuButtons/Btn4,
	$RightArea/MenuButtons/Btn5,
	$RightArea/MenuButtons/Btn6
]

func _ready() -> void:
	_apply_fonts()
	_connect_buttons()
	_update_logo_placeholder(1)
	call_deferred("_arrange_menu_buttons")
	if btn_list.size() > 0 and btn_list[0].has_method("set_selected"):
		btn_list[0].set_selected(true)

func _apply_fonts() -> void:
	var black_han: Font = _load_font("res://assets/fonts/BlackHanSans-Regular.ttf")
	if black_han:
		for node in [title_label, $LeftArea/CharInfoRow/CharInfoLabel, $RightArea/WorldContainer/WorldLabel]:
			if is_instance_valid(node):
				node.add_theme_font_override("font", black_han)

func _load_font(path: String) -> Font:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Font

func _arrange_menu_buttons() -> void:
	if not menu_buttons or btn_list.is_empty():
		return
	for i in btn_list.size():
		var center_screen: Vector2 = BUTTON_CENTERS_SCREEN[i]
		var pos: Vector2 = Vector2(center_screen.x - RIGHT_AREA_LEFT, center_screen.y) - Vector2(BUTTON_SIZE / 2, BUTTON_SIZE / 2)
		btn_list[i].position = pos
		btn_list[i].size = Vector2(BUTTON_SIZE, BUTTON_SIZE)

func _connect_buttons() -> void:
	for btn in btn_list:
		if btn.has_signal("pressed"):
			btn.pressed.connect(_on_menu_button_pressed)

func _on_menu_button_pressed(index: int) -> void:
	for i in btn_list.size():
		if btn_list[i].has_method("set_selected"):
			btn_list[i].set_selected(i + 1 == index)
	_update_logo_placeholder(index)
	match index:
		1:
			get_tree().change_scene_to_file("res://scenes/game/GameManager.tscn")
		2:
			print("신 선택 미구현")
		3:
			print("스테이지 선택 미구현")
		4:
			print("용병 도감 미구현")
		5:
			print("설정 미구현")
		6:
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
