extends CanvasLayer
## 전투 HUD - 턴 표시, 개기월식 게이지, 선택 유닛 정보, Q 스킬, 턴 종료 버튼

@onready var turn_label: Label = $TopRow/TurnLabel
@onready var turn_count_label: Label = $TopRow/TurnCountLabel
@onready var eclipse_gauge: ProgressBar = $TopRow/EclipseBox/EclipseGauge
@onready var unit_name_label: Label = $UnitInfoPanel/MarginContainer/VBox/UnitNameLabel
@onready var unit_hp_label: Label = $UnitInfoPanel/MarginContainer/VBox/HPLabel
@onready var unit_ap_label: Label = $UnitInfoPanel/MarginContainer/VBox/UnitAPLabel
@onready var q_button: Button = $SkillRow/QButton
@onready var turn_end_button: Button = $SkillRow/TurnEndButton
var direction_overlay: CanvasLayer = null

func _ready() -> void:
	var overlay_scn = load("res://scenes/ui/DirectionSelectOverlay.tscn") as PackedScene
	if overlay_scn:
		direction_overlay = overlay_scn.instantiate()
		get_parent().add_child.call_deferred(direction_overlay)

func _process(_delta: float) -> void:
	_update_turn_display()
	_update_eclipse_gauge()
	_update_unit_info()
	_update_q_button()
	if turn_end_button:
		turn_end_button.disabled = GameState.game_over

func _update_turn_display() -> void:
	if turn_label:
		turn_label.text = "플레이어 턴" if GameState.is_player_turn else "AI 턴"
	if turn_count_label:
		turn_count_label.text = "턴: %d" % GameState.current_turn

func _update_eclipse_gauge() -> void:
	if eclipse_gauge:
		eclipse_gauge.value = clampf(float(GameState.eclipse_gauge), 0.0, 100.0)

func _update_unit_info() -> void:
	var unit = GameState.selected_unit
	if not unit:
		if unit_name_label:
			unit_name_label.text = "-"
		if unit_hp_label:
			unit_hp_label.text = "HP: -"
		if unit_ap_label:
			unit_ap_label.text = "AP: -"
		return
	if unit_name_label:
		unit_name_label.text = unit.unit_name if unit.unit_name else "-"
	if unit_hp_label:
		unit_hp_label.text = "HP: %d / %d" % [unit.hp, unit.hp_max]
	if unit_ap_label:
		unit_ap_label.text = "AP: %d" % unit.ap

func _update_q_button() -> void:
	if not q_button:
		return
	if GameState.game_over:
		q_button.disabled = true
		return
	var unit = GameState.selected_unit
	if not unit or not unit.is_player_unit:
		q_button.disabled = true
		q_button.text = "Q"
		return
	if unit.ap < 1:
		q_button.disabled = true
		q_button.text = "Q" if unit.q_skill_cooldown <= 0 else "Q (%d)" % unit.q_skill_cooldown
		return
	if unit.q_skill_cooldown > 0:
		q_button.disabled = true
		q_button.text = "Q (%d)" % unit.q_skill_cooldown
		return
	q_button.disabled = false
	q_button.text = "Q"

func _on_q_button_pressed() -> void:
	var map = get_parent().get_node_or_null("Map")
	if map == null:
		return
	if not map.has_method("request_q_skill"):
		return
	var ok = map.request_q_skill()
	if ok and map.skill_mode in ["q_dir_aegis", "q_dir_artemis"] and direction_overlay:
		var unit = GameState.selected_unit
		if unit:
			direction_overlay.show_for_unit(map, unit.grid_pos)

func _on_turn_end_pressed() -> void:
	if GameState.game_over:
		return
	var tm = get_tree().get_first_node_in_group("turn_manager")
	if tm != null:
		tm.end_player_turn()
