extends ColorRect
## BgGradient - 배경 방사형 그라디언트 (중앙 흰빛 5% → 외곽 투명)

func _ready() -> void:
	if ResourceLoader.exists("res://assets/shaders/radial_gradient.gdshader"):
		var shader := load("res://assets/shaders/radial_gradient.gdshader") as Shader
		if shader:
			material = ShaderMaterial.new()
			(material as ShaderMaterial).shader = shader
