extends Control
## 스킬 정보 UI - 아치형 원, QWER/PS 탭, 스킬 선택

var skills_main: Dictionary = {
	"Q": {"name": "결계 강화", "desc": "링크 라인 내구도 +50%, 3초간 유지"},
	"W": {"name": "기운 충전", "desc": "주변 2타일 아군 이동속도 +20%"},
	"E": {"name": "봉인술", "desc": "적 1기 행동 불능, 2초간"},
	"R": {"name": "천지개벽", "desc": "전체 링크 라인 즉시 복구"},
}
var skills_passive: Dictionary = {
	"P": {"name": "분할된 시야", "desc": "링크 시야 범위 +1타일 (패시브)"},
	"S": {"name": "전환 강화", "desc": "Shift 사용 시 링크 속도 +30%"},
}

const ARCH_CENTER: Vector2 = Vector2(960, 900)  # 아치 상단 배치 (호가 위에)
const BTN_RADIUS: float = 810.0  # 750 + 60
var current_tab: int = 0  # 0=QWER, 1=PS
var selected_key: String = ""
var skill_btns: Dictionary = {}
var skill_labels: Dictionary = {}  # P, S 레이블
var projection_labels: Dictionary = {}  # Q,W,E,R,P,S 가운데 이미지 투영
var hovered_key: String = ""  # 현재 호버된 스킬 키
var _hover_sequence: int = 0  # unhovered 시 다른 버튼으로 이동 여부 구분용

@onready var page_title: Label = $PageTitle
@onready var skill_name_label: Label = $SkillNameLabel
@onready var skill_desc_label: Label = $SkillDescLabel
@onready var arch_circle: Node2D = $ArchCircle
@onready var skill_buttons: Control = $SkillButtons
@onready var char_display: Control = $CharacterDisplay
@onready var char_main: ColorRect = $CharacterDisplay/CharMain
@onready var char_small: ColorRect = $CharacterDisplay/CharSmall
@onready var skill_icon: ColorRect = $SkillIcon
@onready var tab_indicator: Node2D = $TabIndicator
@onready var char_subtitle: Label = $CharSubtitle
@onready var char_name_label: Label = $CharNameLabel
@onready var brand_label: Label = $BrandLabel

func _apply_fonts() -> void:
	var black_han: Font = _load_font("res://assets/fonts/BlackHanSans-Regular.ttf")
	var noto: Font = _load_font("res://assets/fonts/NotoSansKR-Regular.otf")
	if noto == null:
		noto = _load_font("res://assets/fonts/NotoSansKR-Regular.ttf")
	if noto == null:
		noto = ThemeDB.fallback_font
	if black_han and skill_name_label:
		skill_name_label.add_theme_font_override("font", black_han)
	if noto and skill_desc_label:
		skill_desc_label.add_theme_font_override("font", noto)
	if skill_name_label:
		skill_name_label.add_theme_font_size_override("font_size", 28)
	if skill_desc_label:
		skill_desc_label.add_theme_font_size_override("font_size", 20)
		skill_desc_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.75))

func _load_font(path: String) -> Font:
	return load(path) as Font if ResourceLoader.exists(path) else null

func _ready() -> void:
	_apply_fonts()
	arch_circle.position = ARCH_CENTER
	arch_circle.set_tab(current_tab)
	skill_buttons.position = ARCH_CENTER
	# SkillButtons: 원래 (960,900)에 위치, 자식 버튼 좌표가 상대적이므로 offset 변경 시 화면 밖으로 나감
	# 아치 영역 확장 시에도 기준점 (960,900) 유지
	skill_buttons.offset_left = 960
	skill_buttons.offset_top = 900
	skill_buttons.offset_right = 2660  # 960+1700, 버튼들이 왼쪽(-670~)에 있으므로 영역만 넓게
	skill_buttons.offset_bottom = 1750
	skill_buttons.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# CharacterDisplay가 전체 화면(0,0~1920,1080)이라 SkillButtons보다 뒤에 그려져 입력을 가로챔 -> IGNORE로 통과
	char_display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_setup_projection_labels()
	_setup_skill_buttons()
	_set_initial_state()
	_refresh_tab()

func _input(event: InputEvent) -> void:
	var viewport := get_viewport()
	if viewport == null:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		viewport.set_input_as_handled()
		get_tree().change_scene_to_file("res://scenes/ui/CharacterInfo.tscn")
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var pos: Vector2 = viewport.get_mouse_position()
		if tab_indicator.has_method("is_point_in_rect1") and tab_indicator.has_method("is_point_in_rect2"):
			if tab_indicator.is_point_in_rect1(pos):
				viewport.set_input_as_handled()
				_switch_tab(0)
			elif tab_indicator.is_point_in_rect2(pos):
				viewport.set_input_as_handled()
				_switch_tab(1)

func _switch_tab(tab: int) -> void:
	current_tab = tab
	arch_circle.set_tab(current_tab)
	_refresh_tab()

func _setup_projection_labels() -> void:
	# CharMain 하단에 Q,W,E,R 왼쪽부터 배치
	var qwer_keys: Array[String] = ["Q", "W", "E", "R"]
	var qwer_base_x: float = 830.0
	var qwer_base_y: float = 655.0
	var qwer_step: float = 72.0
	for i in qwer_keys.size():
		var lbl := Label.new()
		lbl.text = qwer_keys[i]
		lbl.add_theme_font_size_override("font_size", 36)
		lbl.add_theme_color_override("font_color", Color(0.15, 0.15, 0.15, 0.95))
		lbl.position = Vector2(qwer_base_x + i * qwer_step, qwer_base_y)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.custom_minimum_size = Vector2(40, 40)
		lbl.visible = false
		lbl.z_index = 50
		lbl.set_meta("tab", "tab1")
		char_display.add_child(lbl)
		projection_labels[qwer_keys[i]] = lbl
	# P,S 탭용: Passive, Shift
	var ps_keys: Array[String] = ["P", "S"]
	var ps_texts: Array[String] = ["Passive", "Shift"]
	var ps_base_x: float = 900.0
	var ps_base_y: float = 655.0
	var ps_step: float = 140.0
	for i in ps_keys.size():
		var k: String = ps_keys[i]
		var lbl := Label.new()
		lbl.text = ps_texts[i]
		lbl.add_theme_font_size_override("font_size", 36)
		lbl.add_theme_color_override("font_color", Color(0.15, 0.15, 0.15, 0.95))
		lbl.position = Vector2(ps_base_x + i * ps_step, ps_base_y)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.custom_minimum_size = Vector2(80, 40)
		lbl.visible = false
		lbl.z_index = 50
		lbl.set_meta("tab", "tab2")
		char_display.add_child(lbl)
		projection_labels[k] = lbl

func _setup_skill_buttons() -> void:
	# 왼쪽부터 Q, W, E, R - ArchCircle DOT_ANGLES_TAB1과 동일 각도로 대칭 배치 (225,255,285,315)
	var qwer_layout: Dictionary = {"Q": 225, "W": 255, "E": 285, "R": 315}
	var ps_layout: Dictionary = {"P": 260, "S": 280}  # DOT_ANGLES_TAB2와 동일
	for key in qwer_layout:
		_create_btn(key, qwer_layout[key], "tab1", "", true)  # hide_label=true
	for key in ps_layout:
		_create_btn(key, ps_layout[key], "tab2", "", true)  # Passive, shift 글자 제거

func _create_btn(key: String, angle_deg: float, tab_name: String, label_text: String, hide_label: bool = false) -> void:
	var btn_script: GDScript = load("res://scripts/ui/SkillBtn.gd") as GDScript
	var inst := Control.new()
	inst.set_script(btn_script)
	inst.setup(key, hide_label)
	inst.set_meta("tab", tab_name)
	var rad: float = deg_to_rad(angle_deg)
	var offset: Vector2 = Vector2(cos(rad), sin(rad)) * BTN_RADIUS
	var btn_half: float = 68.0  # SkillBtn.BTN_SIZE/2 (136), 글로우 포함해 칼자름 방지
	inst.position = offset - Vector2(btn_half, btn_half)
	inst.pressed.connect(_on_skill_pressed)  # pressed 시그널이 이미 key 전달
	# QWER(tab1), P·S(tab2) 모두 호버 시 CharMain 투영
	inst.hovered.connect(_on_btn_hovered)
	inst.unhovered.connect(_on_btn_unhovered)
	skill_buttons.add_child(inst)
	skill_btns[key] = inst
	if label_text != "":
		var lbl := Label.new()
		lbl.text = label_text
		lbl.add_theme_font_size_override("font_size", 22)
		lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		var lbl_offset: Vector2 = Vector2(-90, 0) if key == "P" else Vector2(50, 0)
		lbl.position = offset + lbl_offset - Vector2(0, 11)
		lbl.set_meta("tab", "tab2")
		skill_buttons.add_child(lbl)
		skill_labels[key] = lbl

func _on_btn_hovered(key: String) -> void:
	_hover_sequence += 1
	hovered_key = key
	_update_projection_visibility()

func _on_btn_unhovered(_key: String) -> void:
	# Q->W 이동 시 unhovered가 먼저 오면 잘못 초기화됨 -> 1프레임 뒤에만 clear
	var seq := _hover_sequence
	await get_tree().process_frame
	if _hover_sequence == seq:
		hovered_key = ""
		_update_projection_visibility()

func _update_projection_visibility() -> void:
	# 버튼 고정(선택) 시 다른 버튼 호버해도 변경 없음
	if selected_key != "":
		for k in projection_labels:
			projection_labels[k].visible = false
		return
	var show_qwer: bool = current_tab == 0 and hovered_key != ""
	var show_ps: bool = current_tab == 1 and hovered_key != ""
	for k in projection_labels:
		var lbl: Label = projection_labels[k]
		var tab_meta: String = lbl.get_meta("tab", "tab1")
		var show_this: bool = (show_qwer and tab_meta == "tab1") or (show_ps and tab_meta == "tab2")
		lbl.visible = show_this
		if show_this:
			lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0) if k == hovered_key else Color(0.4, 0.4, 0.4, 0.85))
	_update_hover_bottom_text()

func _update_hover_bottom_text() -> void:
	if selected_key != "":
		return
	if hovered_key != "":
		var key_text: String = hovered_key if hovered_key in ["Q", "W", "E", "R"] else ("Passive" if hovered_key == "P" else "Shift")
		var data: Dictionary = skills_main.get(hovered_key, skills_passive.get(hovered_key, {}))
		skill_name_label.text = key_text
		skill_desc_label.text = data.get("desc", "짧은 스킬 설명문")
	else:
		skill_name_label.text = ""
		skill_desc_label.text = "짧은 스킬 설명문"

func _on_skill_pressed(key: String) -> void:
	# 같은 원 다시 클릭 시 고정 해제, 그 외에는 고정(선택)
	if selected_key == key:
		selected_key = ""
	else:
		selected_key = key
	_select_skill(selected_key)
	_update_skill_display()

func _refresh_tab() -> void:
	for k in skill_btns:
		var btn: Control = skill_btns[k]
		var tab_meta: String = btn.get_meta("tab", "tab1")
		# tab1=큰 원 4개, tab2=P,S
		var show_btn: bool = (current_tab == 0 and tab_meta == "tab1") or (current_tab == 1 and tab_meta == "tab2")
		btn.visible = show_btn
	for k in skill_labels:
		skill_labels[k].visible = (current_tab == 1) and skill_btns.has(k) and skill_btns[k].visible
	if selected_key.is_empty() or not skill_btns.has(selected_key):
		pass
	elif (current_tab == 0 and skill_btns[selected_key].get_meta("tab") != "tab1") or (current_tab == 1 and skill_btns[selected_key].get_meta("tab") != "tab2"):
		selected_key = ""
		_select_skill("")
		_update_skill_display()
	tab_indicator.set_tab(current_tab)
	_update_projection_visibility()

func _set_initial_state() -> void:
	# 이미지·제목·요약 설명 위로 배치 (호 아래, x=960 중앙)
	char_main.position = Vector2(800, 350)  # 320px → 중앙 960
	char_main.size = Vector2(320, 350)
	char_main.color = Color(0.88, 0.88, 0.88, 1)
	char_main.modulate.a = 1.0
	char_small.position = Vector2(1050, 780)
	char_small.size = Vector2(160, 300)
	char_small.modulate.a = 0.0
	char_small.visible = false  # 하단 박스 제거
	skill_icon.position = Vector2(860, 200)  # 200x200, 호 중앙
	skill_icon.size = Vector2(200, 200)
	skill_icon.color = Color(1, 1, 1, 1)
	skill_icon.modulate.a = 0.0
	char_subtitle.text = "관측의 절도사"
	char_name_label.text = "세릴리아"
	skill_name_label.text = ""
	skill_desc_label.text = "짧은 스킬 설명문"
	skill_name_label.modulate.a = 1.0
	skill_desc_label.modulate.a = 1.0

func _select_skill(key: String) -> void:
	for k in skill_btns:
		skill_btns[k].is_selected = (k == key)
		skill_btns[k].queue_redraw()
	# 이미지·텍스트 위치 고정 (CharMain 이동 없음), 하단·상단 박스 제거
	char_small.visible = false
	skill_icon.modulate.a = 0.0  # 상단 박스(skill_icon) 제거

func _update_skill_display() -> void:
	if selected_key.is_empty():
		skill_name_label.text = ""
		skill_desc_label.text = "짧은 스킬 설명문"
		skill_name_label.modulate.a = 1.0
		skill_desc_label.modulate.a = 1.0
		return
	var data: Dictionary = skills_main.get(selected_key, skills_passive.get(selected_key, {}))
	skill_name_label.text = data.get("name", "")
	skill_desc_label.text = data.get("desc", "")
	skill_name_label.modulate.a = 1.0
	skill_desc_label.modulate.a = 1.0
