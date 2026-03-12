extends Control
## 반원 호 바깥쪽 마름모 1개 - 마름모 고정, 빛이 발광하는 효과

const DIAMOND_SIZE: float = 8.0

var _glow_radius_val: float = 0.0
var glow_radius: float:
	get: return _glow_radius_val
	set(v):
		_glow_radius_val = v
		queue_redraw()

var _glow_alpha_val: float = 0.0
var glow_alpha: float:
	get: return _glow_alpha_val
	set(v):
		_glow_alpha_val = v
		queue_redraw()

func _draw() -> void:
	var c: Vector2 = size / 2.0

	# 마름모에서 발광하는 빛 (바깥에서 안쪽으로 그라데이션)
	if glow_radius > 0.01 and glow_alpha > 0.01:
		for j in range(8, 0, -1):
			var t: float = float(j) / 8.0
			var r: float = glow_radius * t
			var a: float = 0.25 * glow_alpha * (1.0 - t * t)
			draw_circle(c, r, Color(1, 1, 1, a))

	# 마름모 (크기 고정 8px)
	var pts: PackedVector2Array = [
		c + Vector2(0, -DIAMOND_SIZE),
		c + Vector2(DIAMOND_SIZE, 0),
		c + Vector2(0, DIAMOND_SIZE),
		c + Vector2(-DIAMOND_SIZE, 0)
	]
	draw_colored_polygon(pts, Color(1, 1, 1, 1))
