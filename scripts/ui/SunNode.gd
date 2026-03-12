extends Node2D
## 태양 - 글로우 8겹 + PointLight2D 발광 + 흰색 본체

func _ready() -> void:
	var light := PointLight2D.new()
	light.color = Color(1, 1, 1, 1.0)
	light.energy = 0.5
	light.texture_scale = 3.0
	light.blend_mode = Light2D.BLEND_MODE_ADD
	var tex := load("res://assets/textures/light_circle_gradient.tres") as GradientTexture2D
	if tex:
		light.texture = tex
	add_child(light)

func _draw() -> void:
	# 공기산층 같은 뿌연 발광 - 바깥에서 안쪽으로, 부드럽게 퍼지는 그라디언트
	const CORE_RADIUS := 48.0
	const GLOW_RADIUS := 260.0
	const LAYERS := 40
	for i in LAYERS:
		var t: float = float(i) / float(LAYERS - 1)
		var r: float = lerpf(GLOW_RADIUS, CORE_RADIUS + 2.0, 1.0 - t * t)
		var dist_norm: float = (r - CORE_RADIUS) / (GLOW_RADIUS - CORE_RADIUS)
		var falloff: float = 1.0 - dist_norm
		falloff = falloff * falloff * falloff  # 삼차 곡선 - 더 부드럽게 뿌옇게
		var a: float = lerpf(0.002, 0.12, falloff)
		draw_circle(Vector2.ZERO, r, Color(1, 1, 1, clampf(a, 0.001, 1.0)))
	draw_circle(Vector2.ZERO, CORE_RADIUS, Color(1, 1, 1, 1.0))
