extends Node2D
## 유닛 기본 - 컬러 원, HP바, AP표시

var unit_name: String = ""
var faction: String = ""
var role: String = ""
var hp: int = 100
var hp_max: int = 100
var ap: int = 3
var ap_max: int = 3
var move_range: int = 3
var grid_pos: Vector2i = Vector2i.ZERO
var is_player_unit: bool = true
var q_skill_cooldown: int = 0
var is_marked: bool = false

@onready var unit_circle: Panel = $UnitCircle
@onready var name_label: Label = $NameLabel
@onready var hp_bar: ProgressBar = $HPBar
@onready var ap_label: Label = $APLabel

func _ready() -> void:
	_update_display()

func setup(data: Dictionary) -> void:
	unit_name = data.get("name", "")
	faction = data.get("faction", "")
	role = data.get("role", "")
	hp = data.get("hp", 100)
	hp_max = data.get("hp_max", hp)
	ap = data.get("ap", 3)
	ap_max = data.get("ap_max", 3)
	move_range = data.get("move_range", 3)
	grid_pos = data.get("grid_pos", Vector2i.ZERO)
	is_player_unit = data.get("is_player_unit", true)
	if unit_circle:
		_set_unit_color(data.get("color", Color.WHITE))
		if not is_player_unit:
			_add_ai_border()
	if name_label:
		name_label.text = data.get("name_label", unit_name[0] if unit_name.length() > 0 else "?")
		var c: Color = data.get("color", Color.WHITE)
		name_label.add_theme_color_override("font_color", Color.BLACK if c.get_luminance() > 0.4 else Color.WHITE)
	_update_display()

func _set_unit_color(c: Color) -> void:
	if not unit_circle:
		return
	var style := StyleBoxFlat.new()
	style.bg_color = c
	style.set_corner_radius_all(999)
	unit_circle.add_theme_stylebox_override("panel", style)

func _add_ai_border() -> void:
	if not unit_circle:
		return
	var style: StyleBoxFlat = unit_circle.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if style:
		style.border_color = Color(1.0, 0.2, 0.2)  # #ff3333
		style.set_border_width_all(3)
		unit_circle.add_theme_stylebox_override("panel", style)

func _update_display() -> void:
	if hp_bar:
		hp_bar.max_value = hp_max
		hp_bar.value = hp
		var ratio: float = float(hp) / float(hp_max) if hp_max > 0 else 1.0
		var fill_color: Color
		if ratio >= 0.6:
			fill_color = Color(0.2, 0.8, 0.2)
		elif ratio >= 0.3:
			fill_color = Color(1.0, 1.0, 0.2)
		else:
			fill_color = Color(1.0, 0.2, 0.2)
		var style := StyleBoxFlat.new()
		style.bg_color = fill_color
		hp_bar.add_theme_stylebox_override("fill", style)
	if ap_label:
		ap_label.text = str(ap)

func set_grid_pos(pos: Vector2i) -> void:
	grid_pos = pos

func set_selected(selected: bool) -> void:
	if not unit_circle:
		return
	var style: StyleBoxFlat = unit_circle.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if style:
		if selected:
			style.border_color = Color(1.0, 1.0, 0.0)  # 노란색
			style.set_border_width_all(3)
		else:
			if is_player_unit:
				style.border_color = Color(0, 0, 0, 0)
				style.set_border_width_all(0)
			else:
				style.border_color = Color(1.0, 0.2, 0.2)  # AI: 빨간색 복원
				style.set_border_width_all(3)
		unit_circle.add_theme_stylebox_override("panel", style)
