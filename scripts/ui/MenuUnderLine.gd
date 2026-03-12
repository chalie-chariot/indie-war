extends Control
## 메뉴명 아래 밑줄 (label_width 기준)

@onready var menu_label: Label = get_parent().get_node_or_null("TitleLabel")

func _draw() -> void:
	var w: float = menu_label.size.x if menu_label else 100.0
	var cx: float = size.x * 0.5
	draw_line(
		Vector2(cx - w * 0.5, 0),
		Vector2(cx + w * 0.5, 0),
		Color(1, 1, 1, 0.6),
		1.5
	)
