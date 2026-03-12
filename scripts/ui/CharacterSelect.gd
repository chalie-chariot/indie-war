extends Control
## 캐릭터 선택창 - 카드 6종 + 상세보기

var characters: Array[Dictionary] = [
	{"id": "A", "name": "선인 (仙人)", "color": Color(0.9, 0.9, 0.9, 1)},
	{"id": "B", "name": "무사 (武士)", "color": Color(0.8, 0.8, 0.8, 1)},
	{"id": "C", "name": "음양사", "color": Color(0.85, 0.85, 0.85, 1)},
	{"id": "D", "name": "팔라딘", "color": Color(0.75, 0.75, 0.75, 1)},
	{"id": "E", "name": "궁수", "color": Color(0.7, 0.7, 0.7, 1)},
	{"id": "F", "name": "???", "color": Color(0.3, 0.3, 0.3, 1)},
]
var selected_index: int = 0

const CARD_NAMES: PackedStringArray = ["A", "B", "C", "D", "E", "F"]

@onready var char_sprite: ColorRect = $CharacterDisplay/CharSprite
@onready var char_name_label: Label = $CharacterDisplay/CharNameLabel
@onready var detail_button: Control = $DetailButton
@onready var card_row: HBoxContainer = $CardStrip/CardRow
@onready var page_dots: Control = $PageDots

func _ready() -> void:
	_apply_fonts()
	_setup_cards()
	if detail_button:
		detail_button.gui_input.connect(_on_detail_button_gui_input)
	call_deferred("_update_detail_button_position")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
		accept_event()
		return
	if event.is_action_pressed("ui_left"):
		var next_idx: int = selected_index - 1
		if next_idx >= 0:
			_select_card(next_idx)
			accept_event()
		return
	if event.is_action_pressed("ui_right"):
		var next_idx: int = selected_index + 1
		if next_idx < characters.size():
			_select_card(next_idx)
			accept_event()

func _apply_fonts() -> void:
	var black_han: Font = _load_font("res://assets/fonts/BlackHanSans-Regular.ttf")
	if black_han and char_name_label:
		char_name_label.add_theme_font_override("font", black_han)
	var noto: Font = _load_font("res://assets/fonts/NotoSansKR-Regular.otf")
	if noto and detail_button:
		var dl: Node = detail_button.get_node_or_null("DetailLabel")
		if dl:
			dl.add_theme_font_override("font", noto)

func _update_detail_button_position() -> void:
	if not char_sprite or not detail_button:
		return
	var sprite_pos: Vector2 = char_sprite.global_position
	var sprite_size: Vector2 = char_sprite.size
	# 마름모 중심이 CharSprite 우상단과 맞도록
	detail_button.global_position = sprite_pos + Vector2(sprite_size.x + 16, -18)

func _load_font(path: String) -> Font:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Font

func _setup_cards() -> void:
	for i in 6:
		var card: Control = card_row.get_child(i) as Control
		if not card:
			continue
		var rect: Panel = card.get_node_or_null("CardRect") as Panel
		var label: Label = card.get_node_or_null("CardLabel") as Label
		if rect:
			rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var base: StyleBox = rect.get_theme_stylebox("panel")
			if base:
				var style: StyleBoxFlat = base.duplicate() as StyleBoxFlat
				if style:
					style.bg_color = Color(1, 1, 1, 1) if i < 5 else Color(0.2, 0.2, 0.2, 1)
					rect.add_theme_stylebox_override("panel", style)
		if label:
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if label and i < 6:
			label.text = CARD_NAMES[i]
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if i < 5 else Control.CURSOR_FORBIDDEN
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		card.gui_input.connect(_on_card_gui_input.bind(i))
	_update_display()

func _update_display() -> void:
	if characters.is_empty():
		return
	var ch: Dictionary = characters[selected_index]
	char_sprite.color = ch.get("color", Color(1, 1, 1, 1))
	char_name_label.text = ch.get("name", "이름")
	_update_card_glow()

const CARD_SIZE_SELECTED: Vector2 = Vector2(80, 100)
const CARD_SIZE_NORMAL: Vector2 = Vector2(56, 70)
const CARD_RECT_H_SELECTED: float = 86.0
const CARD_RECT_H_NORMAL: float = 60.0
const CARD_TWEEN_DURATION: float = 0.06

func _update_card_glow() -> void:
	for i in card_row.get_child_count():
		var card: Control = card_row.get_child(i) as Control
		if not card:
			continue
		var is_selected: bool = (i == selected_index and i < 5)
		var target_size: Vector2 = CARD_SIZE_SELECTED if is_selected else CARD_SIZE_NORMAL
		var rect: Panel = card.get_node_or_null("CardRect") as Panel
		if rect:
			var target_rect_h: float = CARD_RECT_H_SELECTED if is_selected else CARD_RECT_H_NORMAL
			var tween := create_tween()
			tween.set_parallel(true)
			tween.tween_property(card, "custom_minimum_size", target_size, CARD_TWEEN_DURATION).set_ease(Tween.EASE_OUT)
			tween.tween_property(rect, "custom_minimum_size", Vector2(target_size.x, target_rect_h), CARD_TWEEN_DURATION).set_ease(Tween.EASE_OUT)
			rect.modulate = Color(1.05, 1.05, 1.05, 1) if is_selected else Color(1, 1, 1, 1)

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
	selected_index = index
	char_sprite.color = characters[index].get("color", Color.WHITE)
	char_name_label.text = characters[index].get("name", "이름")
	_update_card_glow()

func _on_detail_button_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var mb: InputEventMouseButton = event as InputEventMouseButton
	if mb.button_index != MOUSE_BUTTON_LEFT or not mb.pressed:
		return
	_on_detail_click()

func _on_detail_click() -> void:
	if selected_index == 0:
		get_tree().change_scene_to_file("res://scenes/ui/CharacterInfo.tscn")
	# 나머지는 아무 반응 없음
