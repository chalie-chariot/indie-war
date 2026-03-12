extends Node2D
## 이동(파란) / 공격(빨강) / 스킬 방향(시안) / 회복 대상(초록) 반투명 표시

var reachable_tiles: Array = []
var attackable_tiles: Array = []
var skill_tiles: Array = []
var skill_tiles_heal: bool = false
var tile_size: int = 80
var highlight_color: Color = Color(0.2, 0.4, 1.0, 0.4)
var attack_color: Color = Color(1.0, 0.2, 0.2, 0.4)
var skill_direction_color: Color = Color(0.2, 0.8, 1.0, 0.5)
var skill_heal_color: Color = Color(0.2, 0.9, 0.2, 0.5)

func set_tiles(tiles: Array) -> void:
	reachable_tiles = tiles
	attackable_tiles = []
	skill_tiles = []
	queue_redraw()

func set_attackable_tiles(tiles: Array) -> void:
	attackable_tiles = tiles
	queue_redraw()

func set_skill_tiles(tiles: Array, is_heal: bool = false) -> void:
	skill_tiles = tiles
	skill_tiles_heal = is_heal
	queue_redraw()

func set_tiles_and_attackable(reachable: Array, attackable: Array) -> void:
	reachable_tiles = reachable
	attackable_tiles = attackable
	skill_tiles = []
	queue_redraw()

func set_tiles_attackable_skill(reachable: Array, attackable: Array, skill: Array, is_heal: bool = false) -> void:
	reachable_tiles = reachable
	attackable_tiles = attackable
	skill_tiles = skill
	skill_tiles_heal = is_heal
	queue_redraw()

func clear_skill_tiles() -> void:
	skill_tiles = []
	queue_redraw()

func _draw() -> void:
	for pos in reachable_tiles:
		var rect := Rect2(pos.x * tile_size, pos.y * tile_size, tile_size, tile_size)
		draw_rect(rect, highlight_color)
	for pos in attackable_tiles:
		var rect := Rect2(pos.x * tile_size, pos.y * tile_size, tile_size, tile_size)
		draw_rect(rect, attack_color)
	for pos in skill_tiles:
		var rect := Rect2(pos.x * tile_size, pos.y * tile_size, tile_size, tile_size)
		draw_rect(rect, skill_heal_color if skill_tiles_heal else skill_direction_color)
