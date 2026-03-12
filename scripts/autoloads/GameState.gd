extends Node
## GameState - Autoload
## 전역 게임 상태 관리

var selected_character_index: int = 0
var current_turn: int = 1
var is_player_turn: bool = true
var eclipse_gauge: int = 0
var eclipse_triggered: bool = false
var selected_unit = null
var player_units: Array = []
var ai_units: Array = []
var direction_select_active: bool = false
var game_over: bool = false
