extends Node
## EventBus - Autoload
## 게임 전체에서 사용하는 시그널을 한 곳에서 관리하는 싱글톤

# 링크 & 영역 관련
signal link_started(player_id: int)
signal link_unit_added(unit: Node)
signal link_completed(polygon: PackedVector2Array, player_id: int)
signal link_broken(polygon_id: int)
signal territory_claimed(polygon_id: int, player_id: int)
signal territory_lost(polygon_id: int)

# 자원 관련
signal gold_changed(player_id: int, amount: int)
signal resource_collected(player_id: int, tile_pos: Vector2i)

# 유닛 관련
signal unit_spawned(unit: Node)
signal unit_died(unit: Node)
signal unit_selected(unit: Node)
signal unit_deselected(unit: Node)

# AI 관련
signal ai_state_changed(new_state: String)

# 게임 흐름
signal game_started()
signal game_ended(winner: int)
signal sanctuary_capture_progress(player_id: int, progress: float)
