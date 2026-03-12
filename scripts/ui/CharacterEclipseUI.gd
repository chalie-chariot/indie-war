extends Control
## 월식 원 (SunNode + MoonNode) - 상단 중앙

@onready var moon_node: Node2D = $SunNode/MoonNode

func _update_eclipse(index: int, total: int = 5) -> void:
	if not moon_node:
		return
	var denom: float = maxf(1.0, float(total - 1))
	var ratio: float = float(index) / denom
	moon_node.cover_offset = (1.0 - ratio) * 104.0
	moon_node.queue_redraw()
