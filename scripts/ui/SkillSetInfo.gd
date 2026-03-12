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

const ARCH_CENTER: Vector2 = Vector2(728, 820)
const ARCH_RADIUS: float = 580.0
var current_tab: int = 0  # 0=QWER, 1=PS
var selected_key: String = ""
var skill_btns: Dictionary = {}

@onready var page_title: Label = $PageTitle
@onready var skill_name_label: Label = $SkillNameLabel
@onready var skill_desc_label: Label = $SkillDescLabel
@onready var arch_circle: Node2D = $ArchCircle
@onready var skill_buttons: Control = $SkillButtons
@onready var char_display: Control = $CharacterDisplay
@onready var char_main: ColorRect = $CharacterDisplay/CharMain
@onready var char_small: ColorRect = $CharacterDisplay/CharSmall
@onready var tab_indicator: HBoxContainer = $TabIndicator
@onready var tab1: ColorRect = $TabIndicator/Tab1
@onready var tab2: ColorRect = $TabIndicator/Tab2
@onready var char_subtitle: Label = $CharSubtitle
@onready var char_name_label: Label = $CharNameLabel
@onready var brand_label: Label = $BrandLabel

func _ready() -> void:
	arch_circle.position = ARCH_CENTER
	skill_buttons.position = ARCH_CENTER
	_setup_skill_buttons()
	_setup_tabs()
	_set_initial_state()
	_refresh_tab()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://scenes/ui/CharacterInfo.tscn")
		get_viewport().set_input_as_handled()

func _setup_skill_buttons() -> void:
	var qwer_layout: Dictionary = {
		"Q": 210, "W": 225, "E": 315, "R": 330
	}
	var ps_layout: Dictionary = {
		"P": 225, "S": 315
	}
	for key in qwer_layout:
		_create_btn(key, qwer_layout[key], "tab1")
	for key in ps_layout:
		_create_btn(key, ps_layout[key], "tab2")

func _create_btn(key: String, angle_deg: float, tab_name: String) -> void:
	var btn_script: GDScript = load("res://scripts/ui/SkillBtn.gd") as GDScript
	var inst := Control.new()
	inst.set_script(btn_script)
	inst.setup(key)
	inst.set_meta("tab", tab_name)
	var rad: float = deg_to_rad(angle_deg)
	var offset: Vector2 = Vector2(cos(rad), sin(rad)) * ARCH_RADIUS
	inst.position = offset - Vector2(32, 32)
	inst.pressed.connect(_on_skill_pressed.bind(key))
	skill_buttons.add_child(inst)
	skill_btns[key] = inst

func _setup_tabs() -> void:
	tab1.mouse_filter = Control.MOUSE_FILTER_STOP
	tab2.mouse_filter = Control.MOUSE_FILTER_STOP
	tab1.gui_input.connect(_on_tab_input.bind(0))
	tab2.gui_input.connect(_on_tab_input.bind(1))

func _on_tab_input(event: InputEvent, tab: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		current_tab = tab
		_refresh_tab()

func _on_skill_pressed(key: String) -> void:
	selected_key = key if selected_key != key else ""
	_select_skill(selected_key)
	_update_skill_display()

func _refresh_tab() -> void:
	tab1.color = Color(1, 1, 1, 1.0 if current_tab == 0 else 0.3)
	tab2.color = Color(1, 1, 1, 1.0 if current_tab == 1 else 0.3)
	for k in skill_btns:
		var btn: Control = skill_btns[k]
		var tab_meta: String = btn.get_meta("tab", "tab1")
		btn.visible = (current_tab == 0 and tab_meta == "tab1") or (current_tab == 1 and tab_meta == "tab2")
	if selected_key.is_empty() or not skill_btns.has(selected_key):
		pass
	elif (current_tab == 0 and skill_btns[selected_key].get_meta("tab") != "tab1") or (current_tab == 1 and skill_btns[selected_key].get_meta("tab") != "tab2"):
		selected_key = ""
		_select_skill("")
		_update_skill_display()

func _set_initial_state() -> void:
	char_main.position = Vector2(588, 150)
	char_main.size = Vector2(280, 500)
	char_main.color = Color(0.9, 0.9, 0.9, 1)
	char_main.modulate.a = 1.0
	char_small.position = Vector2(1030, 575)
	char_small.size = Vector2(140, 250)
	char_small.modulate.a = 0.0
	char_subtitle.text = "관측의 절도사"
	char_name_label.text = "세릴리아"
	skill_name_label.text = ""
	skill_desc_label.text = "짧은 스킬 설명문"

func _select_skill(key: String) -> void:
	for k in skill_btns:
		skill_btns[k].is_selected = (k == key)
		skill_btns[k].queue_redraw()
	if key.is_empty():
		var t := create_tween()
		t.set_parallel(true)
		t.tween_property(char_main, "position", Vector2(728 - 140, 400 - 250), 0.3).set_ease(Tween.EASE_OUT)
		t.tween_property(char_main, "size", Vector2(280, 500), 0.3).set_ease(Tween.EASE_OUT)
		t.tween_property(char_small, "modulate:a", 0.0, 0.2)
	else:
		var t := create_tween()
		t.set_parallel(true)
		t.tween_property(char_main, "position", Vector2(1100 - 70, 700 - 125), 0.3).set_ease(Tween.EASE_OUT)
		t.tween_property(char_main, "size", Vector2(140, 250), 0.3).set_ease(Tween.EASE_OUT)
		t.tween_property(char_small, "modulate:a", 1.0, 0.2)
		char_small.position = Vector2(1100 - 70, 700 - 125)
		char_small.size = Vector2(140, 250)

func _update_skill_display() -> void:
	if selected_key.is_empty():
		skill_name_label.text = ""
		skill_desc_label.text = "짧은 스킬 설명문"
		return
	var data: Dictionary = skills_main.get(selected_key, skills_passive.get(selected_key, {}))
	skill_name_label.text = data.get("name", "")
	skill_desc_label.text = data.get("desc", "")
