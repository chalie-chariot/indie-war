extends Control
## 인디케이터 2번 - 가운데 반짝이는 아이콘 (클릭 시 SkillSetInfo)

var icon_btn: Control

func _ready() -> void:
	custom_minimum_size = Vector2(400, 140)
	icon_btn = Control.new()
	icon_btn.set_script(load("res://scripts/ui/ShiningIconButton.gd") as GDScript)
	icon_btn.clicked.connect(_on_icon_clicked)
	add_child(icon_btn)
	icon_btn.set_anchors_preset(Control.PRESET_CENTER)
	icon_btn.offset_left = -50
	icon_btn.offset_top = -50
	icon_btn.offset_right = 50
	icon_btn.offset_bottom = 50

func _on_icon_clicked() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/SkillSetInfo.tscn")
