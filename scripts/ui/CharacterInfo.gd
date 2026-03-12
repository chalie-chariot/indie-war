extends Control
## 캐릭터 정보 - 캐릭터 상세 설명, 월식 UI, 스크롤

var characters: Array[Dictionary] = [
	{"name": "선인 (仙人)", "role": "링크 거점",
	 "desc": "결계 강화: 본인이 속한 링크 라인의 내구도 +50%\n동양 공통 유닛. 전략적 거점 확보에 특화된 선인."},
	{"name": "무사 (武士)", "role": "근접 전투",
	 "desc": "기합: 주변 2타일 유닛에게 공격력 +20% 3초간\n동양 공통 유닛. 근접 전투의 핵심 전력."},
	{"name": "음양사", "role": "원거리/디버프",
	 "desc": "저주 부적: 적 유닛 이동속도 -30%, 링크 범위 -2타일\n동양 공통 유닛. 적의 전열을 교란하는 술사."},
	{"name": "팔라딘", "role": "링크 거점",
	 "desc": "신성 방패: 본인 주변 2타일 링크 라인 실드 생성\n서양 공통 유닛. 견고한 방어선을 구축하는 성기사."},
	{"name": "궁수", "role": "원거리",
	 "desc": "저격: 단일 유닛에게 고피해, 링크 라인 파괴 가능\n서양 공통 유닛. 원거리에서 적 링크를 끊는 사수."},
]

var current_index: int = 0
var _wheel_cooldown: float = 0.0

const INDEX_TOP: int = 0  ## 리스트 맨 위 = 첫 번째 캐릭터

@onready var page_title: Label = $PageTitle
@onready var moon_circle: Node2D = $EclipseUI/MoonCircle
@onready var progress_bar: Node2D = $EclipseUI/ProgressBar
@onready var scribe_text: Label = $ScribeText
@onready var char_indicators: Control = $CharScrollIndicators

func _ready() -> void:
	_apply_fonts()
	if char_indicators:
		char_indicators.set_dot_count(characters.size())
		char_indicators.index_selected.connect(_on_indicator_selected)
	_update_display()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
		accept_event()
		return

func _unhandled_input(event: InputEvent) -> void:
	## 휠 기준: TOP=첫 번째(0), BOTTOM=마지막 - 휠 아래=BOTTOM 방향, 휠 위=TOP 방향
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if not mb.pressed:
			return
		if _wheel_cooldown > 0.0:
			accept_event()
			return
		var toward_bottom: bool = false
		var toward_top: bool = false
		match mb.button_index:
			MOUSE_BUTTON_WHEEL_DOWN:
				toward_bottom = true
			MOUSE_BUTTON_WHEEL_UP:
				toward_top = true
		if toward_bottom:
			_scroll_toward_bottom()
			_wheel_cooldown = 0.15
			accept_event()
		elif toward_top:
			_scroll_toward_top()
			_wheel_cooldown = 0.15
			accept_event()

func _process(delta: float) -> void:
	_wheel_cooldown = maxf(0.0, _wheel_cooldown - delta)

func _apply_fonts() -> void:
	var black_han: Font = _load_font("res://assets/fonts/BlackHanSans-Regular.ttf")
	if black_han and page_title:
		page_title.add_theme_font_override("font", black_han)
	var noto: Font = _load_font("res://assets/fonts/NotoSansKR-Regular.otf")
	if not noto:
		noto = _load_font("res://assets/fonts/NotoSansKR-Regular.ttf")
	if noto and scribe_text:
		scribe_text.add_theme_font_override("font", noto)

func _load_font(path: String) -> Font:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Font

func _scroll_toward_top() -> void:
	## 휠 위 = 리스트 TOP(첫 번째) 방향
	if current_index <= INDEX_TOP:
		return
	current_index -= 1
	_update_display()

func _scroll_toward_bottom() -> void:
	## 휠 아래 = 리스트 BOTTOM(마지막) 방향
	var index_bottom: int = characters.size() - 1
	if current_index >= index_bottom:
		return
	current_index += 1
	_update_display()

func _update_display() -> void:
	if characters.is_empty():
		return
	var ch: Dictionary = characters[current_index]
	scribe_text.text = "%s\n%s\n\n%s" % [ch.get("name", ""), ch.get("role", ""), ch.get("desc", "")]

	if moon_circle:
		var n: int = characters.size()
		moon_circle.at_end = (n > 1 and current_index == n - 1)
		moon_circle.phase_offset = -104.0 + 104.0 * float(current_index) / maxf(1.0, float(n - 1)) if n > 1 else 0.0
		moon_circle.queue_redraw()

	if progress_bar and progress_bar.get("progress") != null:
		progress_bar.progress = float(current_index + 1) / float(characters.size())
		progress_bar.queue_redraw()

	if char_indicators:
		char_indicators.set_active(current_index)

	# 페이드 인/아웃
	var tween := create_tween()
	tween.tween_property(scribe_text, "modulate:a", 0.0, 0.1)
	tween.tween_property(scribe_text, "modulate:a", 1.0, 0.2)

func _on_indicator_selected(index: int) -> void:
	current_index = clampi(index, 0, characters.size() - 1)
	_update_display()
