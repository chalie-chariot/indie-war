extends Control
## 캐릭터 정보 - 캐릭터 상세 설명, 월식 UI, 스크롤

var characters: Array = [
	{
		"name": "선인 (仙人)",
		"role": "링크 거점",
		"desc": "결계 강화: 본인이 속한 링크 라인의 내구도 +50%\n\n동양 공통 유닛.\n전략적 거점 확보에 특화된 선인.\n\n유구한 세월을 수련으로 보낸 선인은 대지의 기운을 다루는 능력을 지닌다. 전장에서 그는 말없이 자리를 지키며, 링크 라인 위로 흐르는 기운을 단단히 붙들어 아군의 방어선을 굳힌다.\n\n『산중일기』에 따르면 선인은 본래 속세를 떠나 깊은 산속에서 수행하던 자들이었다. 수십 년의 고된 수련 끝에 얻은 '지기(地氣)'는 대지를 밟는 아군 유닛의 기운을 북돋으며, 링크로 연결된 병사들의 사기를 꺾지 않게 한다. 적이 아무리 포위해도 선인이 서 있는 거점은 함락되지 않는다는 전설이 있다.",
		"stats": [0.8, 0.7, 0.6, 0.9, 0.75]
	},
	{
		"name": "무사 (武士)",
		"role": "근접 전투",
		"desc": "기합: 주변 2타일 유닛에게 공격력 +20% 3초간\n\n동양 공통 유닛.\n근접 전투의 핵심 전력.\n\n전장을 누비며 적의 심장부를 가르는 무사. 그의 기합 한 마디에 아군은 용기를 얻고, 적은 두려움에 발걸음을 멈춘다.\n\n검술과 기합의 이론을 집대성한 『검경』은 이렇게 적었다. \"한 순간의 기합이 전장의 기운을 바꾼다.\" 무사는 수년간의 단련으로 얻은 '단전(丹田)'의 힘을 한 순간 폭발시켜, 주변 아군의 혈기를 끓어오르게 한다. 적장의 목을 베는 순간, 그 기합소리는 적진 전체에 공포를 퍼뜨린다.",
		"stats": [0.9, 0.6, 0.7, 0.5, 0.8]
	},
	{
		"name": "음양사",
		"role": "원거리 / 디버프",
		"desc": "저주 부적: 적 유닛 이동속도 -30%\n링크 범위 -2타일\n\n동양 공통 유닛.\n적의 전열을 교란하는 술사.\n\n음과 양의 이치를 꿰뚫은 술사. 부적 하나로 적의 움직임을 묶고 링크를 끊어내며 전장의 흐름을 뒤바꾼다.\n\n『금기록』에는 음양오행의 원리가 전술과 결합된 사례가 수록되어 있다. 음양사가 써 내려 보내는 '악독부(惡毒符)'는 적군의 다리에 무거운 짐을 지우고, 링크의 기운을 해체한다. 적이 한 발 한 발 움직일 때마다 부적의 저주가 그 몸을 짓누른다.",
		"stats": [0.5, 0.4, 0.6, 0.85, 0.55]
	},
	{
		"name": "팔라딘",
		"role": "링크 거점",
		"desc": "신성 방패: 본인 주변 2타일\n링크 라인 실드 생성\n\n서양 공통 유닛.\n견고한 방어선을 구축하는 성기사.\n\n신의 가호를 받은 성기사. 방패 하나로 전선을 틀어막고 아군의 링크를 수호하며 흔들림 없는 방어선을 만들어낸다.\n\n『성기사 서약』의 구절처럼, 팔라딘은 맹세의 힘으로 '신성결계'를 형성한다. 그 결계 안에서 아군의 링크 라인은 투명한 방벽으로 둘러싸여 적의 공격을 막아낸다. 한 번도 무너진 적이 없다고 전해지는 '철의 성벽' 전투에서, 단 다섯의 팔라딘이 3일 밤낮을 버텼다는 기록이 남아 있다.",
		"stats": [0.6, 0.95, 0.4, 0.9, 0.85]
	},
	{
		"name": "궁수",
		"role": "원거리",
		"desc": "저격: 단일 유닛에게 고피해\n링크 라인 파괴 가능\n\n서양 공통 유닛.\n원거리에서 적 링크를 끊는 사수.\n\n침묵 속에서 적을 겨누는 사수. 단 한 발의 화살로 적의 링크 라인을 파괴하고 전세를 뒤흔드는 저격수.\n\n『궁술지침』에는 \"한 발이 천 병을 물리친다\"는 구절이 있다. 궁수는 수 킬로미터 밖에서도 링크의 핵심을 꿰뚫을 수 있는 예리한 감각을 지녔다. 그들의 화살은 물리적 피해를 넘어, 적의 링크를 형성하는 '기운의 끈' 자체를 절단한다. 전장이 고요해졌을 때, 그것은 궁수가 겨냥하고 있다는 징조다.",
		"stats": [0.85, 0.35, 0.75, 0.5, 0.6]
	},
]
var current_index: int = 0
var current_page: int = 0
var _last_scroll: int = -1

@onready var page_title: Label = $LeftArea/InfoPanel/PageTitle
@onready var char_name_label: Label = $LeftArea/InfoPanel/CharNameLabel
@onready var role_label: Label = $LeftArea/InfoPanel/RoleLabel
@onready var desc_label: Label = $LeftArea/InfoPanel/DescLabel
@onready var desc_scroll: ScrollContainer = $LeftArea/InfoPanel/DescScroll
@onready var info_panel: Control = $LeftArea/InfoPanel
@onready var skill_panel: Control = $LeftArea/SkillIconsPanel
@onready var stats_panel: Control = $LeftArea/StatsPanel
@onready var eclipse_ui: Control = $EclipseUI
@onready var tab_dots: Node2D = $TabDots

func _ready() -> void:
	_apply_fonts()
	# 계기월식·텍스트 박스: 전체적으로 위로
	if eclipse_ui:
		eclipse_ui.position = Vector2(380, 200)
	if tab_dots:
		tab_dots.position = Vector2(950, 700)
	current_index = clampi(GameState.selected_character_index, 0, characters.size() - 1)
	_update_display()
	_refresh_tab()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/ui/CharacterSelect.tscn")
		elif event.keycode == KEY_LEFT or event.keycode == KEY_KP_4:
			_set_page((current_page - 1 + 3) % 3)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_RIGHT or event.keycode == KEY_KP_6:
			_set_page((current_page + 1) % 3)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_DOWN or event.keycode == KEY_KP_2:
			_handle_scroll_down()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_UP or event.keycode == KEY_KP_8:
			_handle_scroll_up()
			get_viewport().set_input_as_handled()
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_handle_scroll_down()
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_handle_scroll_up()
			get_viewport().set_input_as_handled()

func _apply_fonts() -> void:
	# 폰트동일: 모든 텍스트에 동일한 폰트 적용
	var font: Font = _load_font("res://assets/fonts/NotoSansKR-Regular.otf")
	if font == null:
		font = _load_font("res://assets/fonts/NotoSansKR-Regular.ttf")
	if font == null:
		font = ThemeDB.fallback_font
	if font:
		for label in [page_title, char_name_label, role_label, desc_label]:
			if label:
				label.add_theme_font_override("font", font)
	if page_title:
		page_title.add_theme_font_size_override("font_size", 24)
	if char_name_label:
		char_name_label.add_theme_font_size_override("font_size", 52)
	if role_label:
		role_label.add_theme_font_size_override("font_size", 22)
	if desc_label:
		desc_label.add_theme_font_size_override("font_size", 20)

func _load_font(path: String) -> Font:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Font

func _get_max_scroll() -> int:
	var bar: VScrollBar = desc_scroll.get_v_scroll_bar()
	if not bar:
		return 0
	return maxi(0, int(bar.max_value))

func _handle_scroll_down() -> void:
	if current_page == 0:
		# DescLabel은 스크롤 없이 표시 -> 스크롤 다운 시 바로 다음 탭으로
		_set_page(1)
	elif current_page == 1:
		_set_page(2)
	elif current_page == 2:
		# 3번 인디케이터(Stats): bottom 제한 - 스크롤해도 그대로 유지
		pass

func _handle_scroll_up() -> void:
	if current_page == 0:
		# DescLabel은 스크롤 없음 - 스크롤 업 시 아무 동작 없음
		pass
	elif current_page == 1:
		_set_page(0)
	elif current_page == 2:
		_set_page(1)

func _set_page(page: int) -> void:
	current_page = clampi(page, 0, 2)
	if tab_dots and tab_dots.has_method("set_page"):
		tab_dots.set_page(current_page)
	_refresh_tab()

func _refresh_tab() -> void:
	info_panel.visible = current_page == 0
	skill_panel.visible = current_page == 1
	stats_panel.visible = current_page == 2
	if stats_panel and stats_panel.has_method("set_stats"):
		var c: Dictionary = characters[current_index]
		stats_panel.set_stats(c.get("stats", [0.5, 0.5, 0.5, 0.5, 0.5]))

func _process(_delta: float) -> void:
	if desc_scroll and desc_scroll.scroll_vertical != _last_scroll:
		_last_scroll = desc_scroll.scroll_vertical

func _truncate_desc_to_fit(text: String, max_chars: int = 520) -> String:
	## 노란색 마지노선(880px) 넘지 않도록 문장 단위로 축약
	if text.length() <= max_chars:
		return text
	var truncated: String = text.substr(0, max_chars)
	var last_dot: int = truncated.rfind(".")
	var last_ko: int = truncated.rfind("。")
	var last_nl: int = truncated.rfind("\n")
	var last_break: int = maxi(maxi(last_dot, last_ko), last_nl)
	if last_break > max_chars * 0.5:
		return truncated.substr(0, last_break + 1)
	return truncated + "…"

func _update_display() -> void:
	var c: Dictionary = characters[current_index]
	char_name_label.text = c["name"]
	role_label.text = c["role"]
	desc_label.text = _truncate_desc_to_fit(c["desc"])

	for label in [char_name_label, role_label]:
		label.modulate.a = 0.0
		var t := create_tween()
		t.tween_property(label, "modulate:a", 1.0, 0.25)
	# ScrollContainer 내부 desc_label은 즉시 표시 (페이드인 시 레이아웃 이슈 가능)
	desc_label.modulate.a = 1.0

	# 월식 UI
	if eclipse_ui and eclipse_ui.has_method("_update_eclipse"):
		eclipse_ui._update_eclipse(current_index, characters.size())

	_refresh_tab()
