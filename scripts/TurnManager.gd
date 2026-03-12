extends Node
## 턴 관리 - 플레이어/AI 턴 전환, AP 초기화, AI 이동

var map: Node2D = null

func _ready() -> void:
	GameState.game_over = false
	map = get_parent().get_node_or_null("Map")
	add_to_group("turn_manager")
	start_player_turn(false)

func start_player_turn(from_ai: bool = false) -> void:
	if from_ai:
		GameState.current_turn += 1
	GameState.is_player_turn = true
	for unit in GameState.player_units:
		if not is_instance_valid(unit):
			continue
		if unit.get("ap_max") != null:
			unit.ap = unit.ap_max
		if unit.get("q_skill_cooldown") != null and unit.q_skill_cooldown > 0:
			unit.q_skill_cooldown -= 1
		if unit.has_method("_update_display"):
			unit._update_display()

func end_player_turn() -> void:
	if not GameState.is_player_turn:
		return
	start_ai_turn()

func start_ai_turn() -> void:
	GameState.is_player_turn = false
	GameState.selected_unit = null
	if map and map.has_method("_deselect_unit"):
		map._deselect_unit()
	_run_ai_moves()

func _run_ai_moves() -> void:
	print("AI 턴 시작 - ai_units 수: ", GameState.ai_units.size())
	if not map:
		print("map이 null임")
		_end_ai_turn()
		return
	if not map.has_method("move_unit_to"):
		print("move_unit_to 함수 없음 - Map.gd에 이 함수 추가 필요")
		_end_ai_turn()
		return
	for ai_unit in GameState.ai_units.duplicate():
		var best = _get_best_move_toward_nearest_player(ai_unit)
		print("AI 유닛: ", ai_unit.unit_name, " best_move: ", best)
		if best != Vector2i(-9999, -9999):
			map.move_unit_to(ai_unit, best, false)
	print("AI 턴 종료")
	_end_ai_turn()

func _get_best_move_toward_nearest_player(ai_unit) -> Vector2i:
	if GameState.player_units.is_empty():
		return Vector2i(-9999, -9999)

	var nearest = null
	var min_dist = 9999
	for p in GameState.player_units:
		if not is_instance_valid(p):
			continue
		var d = abs(p.grid_pos.x - ai_unit.grid_pos.x) + abs(p.grid_pos.y - ai_unit.grid_pos.y)
		if d < min_dist:
			min_dist = d
			nearest = p

	if nearest == null:
		return Vector2i(-9999, -9999)

	var directions = [Vector2i(0,-1), Vector2i(0,1), Vector2i(-1,0), Vector2i(1,0)]
	var best = Vector2i(-9999, -9999)
	var best_dist = min_dist

	for dir in directions:
		var next = ai_unit.grid_pos + dir
		if next.x < 0 or next.x >= 12 or next.y < 0 or next.y >= 12:
			continue
		if map.is_tile_occupied(next):
			continue
		var d = abs(nearest.grid_pos.x - next.x) + abs(nearest.grid_pos.y - next.y)
		if d < best_dist:
			best_dist = d
			best = next

	return best

func _end_ai_turn() -> void:
	start_player_turn(true)
