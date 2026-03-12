extends Node2D
## 12×12 타일맵 - 전투 프로토타입
## 1920×1080 기준 화면 정중앙, 타일 80px, 맵 960×960

const MAP_SIZE: int = 12
const TILE_SIZE: int = 80
const TILE_COLOR: Color = Color(0.176, 0.176, 0.176)  # #2d2d2d
const TILE_BORDER: Color = Color(0.227, 0.227, 0.227)  # #3a3a3a

var tile_map: TileMap
var units_layer: Node2D
var highlight_layer: Node2D
var map_highlight: Node2D  # 이동 가능 타일 표시
var tile_data: Dictionary = {}  # key: Vector2i / value: {unit: BaseUnit or null, type: String}
var selected_unit: Node = null  # BaseUnit
var skill_mode: String = ""  # "", "q_dir_aegis", "q_dir_artemis", "q_heal"

const BASE_UNIT_SCENE: PackedScene = preload("res://scenes/units/BaseUnit.tscn")
const EMPTY_VECTOR2I_ARRAY: Array = []
const ATTACK_DAMAGE: int = 15
const Q_SKILL_COOLDOWN: int = 2

# 유닛 3종 데이터
const UNIT_CONFIGS: Array[Dictionary] = [
	{"name": "아이게온", "name_label": "아", "faction": "솔페란", "role": "탱커", "hp": 120, "hp_max": 120, "ap": 3, "ap_max": 3, "move_range": 2, "color": Color(0.867, 0.867, 0.867)},  # #dddddd
	{"name": "슈처", "name_label": "슈", "faction": "엘노르", "role": "힐러", "hp": 90, "hp_max": 90, "ap": 3, "ap_max": 3, "move_range": 3, "color": Color(0.2, 0.6, 1.0)},   # #3399ff
	{"name": "아르테미스", "name_label": "아르", "faction": "디스마리스", "role": "딜러", "hp": 80, "hp_max": 80, "ap": 3, "ap_max": 3, "move_range": 4, "color": Color(0.133, 0.133, 0.133)},  # #222222
]

func _ready() -> void:
	_setup_tile_map()
	_fill_map()
	_center_on_screen()
	_spawn_units()
	_populate_game_state_units()

func _center_on_screen() -> void:
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	var map_pixel_size: float = MAP_SIZE * TILE_SIZE
	position = Vector2(
		(vp_size.x - map_pixel_size) / 2.0,
		(vp_size.y - map_pixel_size) / 2.0
	)

func _setup_tile_map() -> void:
	# 타일 텍스처 생성 (80×80, #2d2d2d 배경 + #3a3a3a 테두리)
	var img := Image.create_from_data(TILE_SIZE, TILE_SIZE, false, Image.FORMAT_RGBA8, _create_tile_pixels())
	var tex := ImageTexture.create_from_image(img)

	# TileSet 생성
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)

	var atlas := TileSetAtlasSource.new()
	atlas.texture = tex
	atlas.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	atlas.create_tile(Vector2i(0, 0))
	tile_set.add_source(atlas, 0)

	# TileMap에 적용
	tile_map = TileMap.new()
	tile_map.tile_set = tile_set
	tile_map.name = "TileMap"
	add_child(tile_map)

	# UnitsLayer, HighlightLayer (지시서 구조)
	units_layer = Node2D.new()
	units_layer.name = "UnitsLayer"
	add_child(units_layer)

	highlight_layer = Node2D.new()
	highlight_layer.name = "HighlightLayer"
	add_child(highlight_layer)
	var hl_script: GDScript = load("res://scripts/MapHighlight.gd") as GDScript
	map_highlight = Node2D.new()
	map_highlight.set_script(hl_script)
	map_highlight.tile_size = TILE_SIZE
	highlight_layer.add_child(map_highlight)

func _create_tile_pixels() -> PackedByteArray:
	var pixels := PackedByteArray()
	var fill_color := TILE_COLOR
	var border_color := TILE_BORDER
	for y in TILE_SIZE:
		for x in TILE_SIZE:
			var is_border := (x == 0 or x == TILE_SIZE - 1 or y == 0 or y == TILE_SIZE - 1)
			var c: Color = border_color if is_border else fill_color
			pixels.append_array([int(c.r * 255), int(c.g * 255), int(c.b * 255), 255])
	return pixels

func _fill_map() -> void:
	for col in MAP_SIZE:
		for row in MAP_SIZE:
			var pos := Vector2i(col, row)
			tile_map.set_cell(0, pos, 0, Vector2i(0, 0))
			tile_data[pos] = {"unit": null, "type": "normal"}

func world_to_grid(world_pos: Vector2) -> Vector2i:
	var local := global_transform.affine_inverse() * world_pos
	return Vector2i(
		int(local.x / TILE_SIZE),
		int(local.y / TILE_SIZE)
	)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	# Map 로컬 좌표 (타일 중심)
	return Vector2(
		grid_pos.x * TILE_SIZE + TILE_SIZE / 2.0,
		grid_pos.y * TILE_SIZE + TILE_SIZE / 2.0
	)

func is_valid_tile(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < MAP_SIZE and pos.y >= 0 and pos.y < MAP_SIZE

func is_tile_occupied(pos: Vector2i) -> bool:
	if not tile_data.has(pos):
		return false
	return tile_data[pos]["unit"] != null

func get_skill_direction_tiles(unit) -> Array:
	if not unit:
		return []
	var pos: Vector2i = unit.grid_pos
	var dirs: Array = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	var result: Array = []
	for d in dirs:
		var t: Vector2i = pos + d
		if is_valid_tile(t):
			result.append(t)
	return result

func get_skill_heal_target_tiles(unit) -> Array:
	if not unit or not unit.is_player_unit:
		return []
	var pos: Vector2i = unit.grid_pos
	var dirs: Array = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	var result: Array = []
	for d in dirs:
		var t: Vector2i = pos + d
		if not is_valid_tile(t):
			continue
		var u = tile_data[t]["unit"]
		if u != null and u.is_player_unit:
			result.append(t)
	return result

func get_attackable_tiles(unit) -> Array:
	var result: Array = []
	if not unit or unit.get("ap") == null or int(unit.get("ap")) < 1:
		return result
	var pos: Vector2i = unit.grid_pos
	var is_player: bool = unit.get("is_player_unit") == true
	var dirs: Array = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	for d in dirs:
		var target: Vector2i = pos + d
		if not is_valid_tile(target):
			continue
		var cell = tile_data[target]["unit"]
		if cell != null and cell.get("is_player_unit") != is_player:
			result.append(target)
	return result

func get_reachable_tiles(unit) -> Array:
	var result = []
	var pos = unit.grid_pos
	var r = min(unit.move_range, unit.ap)
	print("get_reachable_tiles - unit.ap: ", unit.ap, " move_range: ", unit.move_range, " -> r: ", r)
	for x in range(-r, r + 1):
		for y in range(-r, r + 1):
			if abs(x) + abs(y) <= r and (x != 0 or y != 0):
				var target = Vector2i(pos.x + x, pos.y + y)
				if target.x >= 0 and target.x < 12 and target.y >= 0 and target.y < 12:
					if not is_tile_occupied(target):
						result.append(target)
	return result

func _input(event: InputEvent) -> void:
	if not GameState.is_player_turn:
		return
	if GameState.game_over:
		return
	if GameState.direction_select_active:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var grid_pos: Vector2i = world_to_grid(get_global_mouse_position())
		if not is_valid_tile(grid_pos):
			return
		_handle_tile_click(grid_pos)

func _spawn_units() -> void:
	# 플레이어 유닛: 좌하단 (1,10), (2,10), (3,10)
	var player_positions: Array = [Vector2i(1, 10), Vector2i(2, 10), Vector2i(3, 10)]
	for i in 3:
		var cfg: Dictionary = UNIT_CONFIGS[i].duplicate()
		cfg["grid_pos"] = player_positions[i]
		cfg["is_player_unit"] = true
		_place_unit(cfg)

	# AI 유닛: 우상단 (8,1), (9,1), (10,1)
	var ai_positions: Array = [Vector2i(8, 1), Vector2i(9, 1), Vector2i(10, 1)]
	for i in 3:
		var cfg: Dictionary = UNIT_CONFIGS[i].duplicate()
		cfg["grid_pos"] = ai_positions[i]
		cfg["is_player_unit"] = false
		_place_unit(cfg)

func _populate_game_state_units() -> void:
	GameState.player_units.clear()
	GameState.ai_units.clear()
	for c in units_layer.get_children():
		if c.get("is_player_unit") == true:
			GameState.player_units.append(c)
		else:
			GameState.ai_units.append(c)

func _place_unit(data: Dictionary) -> void:
	var grid_pos: Vector2i = data.get("grid_pos", Vector2i.ZERO)
	if not is_valid_tile(grid_pos):
		return
	if tile_data[grid_pos]["unit"] != null:
		return
	var unit_scn: Node = BASE_UNIT_SCENE.instantiate()
	unit_scn.position = grid_to_world(grid_pos)
	units_layer.add_child(unit_scn)
	if unit_scn.has_method("setup"):
		unit_scn.setup(data)
	if unit_scn.has_method("set_grid_pos"):
		unit_scn.set_grid_pos(grid_pos)
	tile_data[grid_pos]["unit"] = unit_scn

func _handle_tile_click(grid_pos: Vector2i) -> void:
	if skill_mode != "":
		_handle_skill_tile_click(grid_pos)
		return
	var cell: Dictionary = tile_data[grid_pos]
	var unit_there: Node = cell["unit"]
	var reachable: Array = get_reachable_tiles(selected_unit) if selected_unit else EMPTY_VECTOR2I_ARRAY
	var attackable: Array = get_attackable_tiles(selected_unit) if selected_unit else []

	if unit_there != null and unit_there.get("is_player_unit") == true:
		_select_unit(unit_there)
		return
	if grid_pos in attackable and unit_there != null and unit_there.get("is_player_unit") != selected_unit.get("is_player_unit"):
		_attack(selected_unit, unit_there)
		if selected_unit.ap > 0:
			_refresh_selection_highlights()
		else:
			_deselect_unit()
		return
	if grid_pos in reachable:
		_move_unit(selected_unit, grid_pos)
		if selected_unit.ap > 0:
			_refresh_selection_highlights()
		else:
			_deselect_unit()
		return
	_deselect_unit()

func _handle_skill_tile_click(grid_pos: Vector2i) -> void:
	var dir_tiles := get_skill_direction_tiles(selected_unit)
	var heal_tiles := get_skill_heal_target_tiles(selected_unit)
	if skill_mode == "q_dir_aegis" or skill_mode == "q_dir_artemis":
		if grid_pos in dir_tiles:
			var dir: Vector2i = grid_pos - selected_unit.grid_pos
			if skill_mode == "q_dir_aegis":
				_execute_q_aegis(dir)
			else:
				_execute_q_artemis(dir)
			_finish_q_skill()
		else:
			cancel_skill_mode()
	elif skill_mode == "q_heal":
		if grid_pos in heal_tiles and tile_data[grid_pos]["unit"] != null:
			_execute_q_schuzer(tile_data[grid_pos]["unit"])
			_finish_q_skill()
		else:
			cancel_skill_mode()

func _select_unit(unit: Node) -> void:
	_deselect_unit()
	selected_unit = unit
	GameState.selected_unit = unit
	if unit.has_method("set_selected"):
		unit.set_selected(true)
	_refresh_selection_highlights()

func _refresh_selection_highlights() -> void:
	if not selected_unit:
		return
	var reachable: Array = get_reachable_tiles(selected_unit)
	var attackable: Array = get_attackable_tiles(selected_unit)
	if map_highlight and map_highlight.has_method("set_tiles_and_attackable"):
		map_highlight.set_tiles_and_attackable(reachable, attackable)
	elif map_highlight and map_highlight.has_method("set_tiles"):
		map_highlight.set_tiles(reachable)

func _attack(attacker: Node, target: Node) -> void:
	if not attacker or not target or attacker.get("ap") == null or int(attacker.get("ap")) < 1:
		return
	print("기본 공격 - 피해: 15 → ", target.unit_name)
	var new_hp: int = int(target.get("hp")) - ATTACK_DAMAGE
	target.set("hp", max(0, new_hp))
	if target.has_method("_update_display"):
		target._update_display()
	attacker.set("ap", int(attacker.get("ap")) - 1)
	if attacker.has_method("_update_display"):
		attacker._update_display()
	if new_hp <= 0:
		_remove_unit(target)

func _remove_unit(unit: Node) -> void:
	var pos: Vector2i = unit.get("grid_pos")
	if tile_data.has(pos):
		tile_data[pos]["unit"] = null
	GameState.player_units.erase(unit)
	GameState.ai_units.erase(unit)
	if unit.get_parent():
		unit.get_parent().remove_child(unit)
	unit.queue_free()
	_check_win_lose()

func _check_win_lose() -> void:
	var overlay = get_tree().get_first_node_in_group("result_overlay")
	if overlay == null:
		return
	if GameState.ai_units.is_empty():
		overlay.show_result("승리")
	elif GameState.player_units.is_empty():
		overlay.show_result("패배")

func request_q_skill() -> bool:
	if not selected_unit or not selected_unit.is_player_unit or selected_unit.ap < 1 or selected_unit.q_skill_cooldown > 0:
		return false
	var role: String = selected_unit.role
	if role == "탱커":
		skill_mode = "q_dir_aegis"
		if map_highlight and map_highlight.has_method("clear_skill_tiles"):
			map_highlight.clear_skill_tiles()
		return true
	elif role == "힐러":
		var heal_tiles := get_skill_heal_target_tiles(selected_unit)
		if heal_tiles.is_empty():
			return false
		skill_mode = "q_heal"
		if map_highlight and map_highlight.has_method("set_tiles_attackable_skill"):
			map_highlight.set_tiles_attackable_skill([], [], heal_tiles, true)
		elif map_highlight and map_highlight.has_method("set_skill_tiles"):
			map_highlight.set_skill_tiles(heal_tiles, true)
		return true
	elif role == "딜러":
		skill_mode = "q_dir_artemis"
		if map_highlight and map_highlight.has_method("clear_skill_tiles"):
			map_highlight.clear_skill_tiles()
		return true
	return false

func execute_q_direction(dir: Vector2i) -> void:
	if skill_mode == "q_dir_aegis":
		_execute_q_aegis(dir)
		_finish_q_skill()
	elif skill_mode == "q_dir_artemis":
		_execute_q_artemis(dir)
		_finish_q_skill()

func cancel_skill_mode() -> void:
	skill_mode = ""
	if map_highlight and map_highlight.has_method("clear_skill_tiles"):
		map_highlight.clear_skill_tiles()
	_refresh_selection_highlights()

func _finish_q_skill() -> void:
	skill_mode = ""
	selected_unit.ap -= 1
	selected_unit.q_skill_cooldown = Q_SKILL_COOLDOWN
	if selected_unit.has_method("_update_display"):
		selected_unit._update_display()
	if map_highlight and map_highlight.has_method("clear_skill_tiles"):
		map_highlight.clear_skill_tiles()
	_refresh_selection_highlights()
	if selected_unit.ap <= 0:
		_deselect_unit()

func _execute_q_aegis(dir: Vector2i) -> void:
	var pos: Vector2i = selected_unit.grid_pos
	for i in range(1, 3):
		var t: Vector2i = pos + dir * i
		if not is_valid_tile(t):
			break
		var u = tile_data[t]["unit"]
		if u != null and not u.is_player_unit:
			print("꿰뚫는 빛 Q - 피해: 20 → ", u.unit_name)
			_apply_damage(u, 20)
			u.is_marked = true
			break

func _execute_q_artemis(dir: Vector2i) -> void:
	var pos: Vector2i = selected_unit.grid_pos
	for i in range(1, 4):
		var t: Vector2i = pos + dir * i
		if not is_valid_tile(t):
			break
		var u = tile_data[t]["unit"]
		if u != null and not u.is_player_unit:
			print("월흔참 Q - 피해: 25 → ", u.unit_name)
			_apply_damage(u, 25)
			break

func _execute_q_schuzer(target: Node) -> void:
	if not target or not target.is_player_unit:
		return
	print("치료 주사 Q - 회복: 30 → ", target.unit_name)
	target.hp = min(target.hp_max, target.hp + 30)
	if target.has_method("_update_display"):
		target._update_display()

func _apply_damage(unit: Node, amount: int) -> void:
	if not unit:
		return
	unit.hp = max(0, unit.hp - amount)
	if unit.has_method("_update_display"):
		unit._update_display()
	if unit.hp <= 0:
		_remove_unit(unit)

func _deselect_unit() -> void:
	skill_mode = ""
	if selected_unit and selected_unit.has_method("set_selected"):
		selected_unit.set_selected(false)
	selected_unit = null
	GameState.selected_unit = null
	if map_highlight and map_highlight.has_method("set_tiles"):
		map_highlight.set_tiles(EMPTY_VECTOR2I_ARRAY)
	if map_highlight and map_highlight.has_method("set_attackable_tiles"):
		map_highlight.set_attackable_tiles([])
	if map_highlight and map_highlight.has_method("clear_skill_tiles"):
		map_highlight.clear_skill_tiles()

func move_unit_to(unit: Node, to_grid: Vector2i, consume_ap: bool = true) -> bool:
	if not unit or not unit.get("grid_pos"):
		return false
	if is_tile_occupied(to_grid):
		return false
	var from_grid: Vector2i = unit.get("grid_pos")
	var dist: int = abs(to_grid.x - from_grid.x) + abs(to_grid.y - from_grid.y)
	if consume_ap:
		var cur_ap = unit.get("ap")
		if cur_ap == null or int(cur_ap) < dist:
			return false
	if unit.is_marked:
		unit.is_marked = false
		_apply_damage(unit, 10)
		if unit.hp <= 0:
			tile_data[from_grid]["unit"] = null
			return true
	tile_data[from_grid]["unit"] = null
	tile_data[to_grid]["unit"] = unit
	if unit.has_method("set_grid_pos"):
		unit.set_grid_pos(to_grid)
	unit.position = grid_to_world(to_grid)
	if consume_ap:
		var cur_ap = unit.get("ap")
		unit.set("ap", max(0, int(cur_ap) - dist))
	if unit.has_method("_update_display"):
		unit._update_display()
	return true

func _move_unit(unit: Node, to_grid: Vector2i) -> void:
	move_unit_to(unit, to_grid, true)
