extends CanvasLayer
## 승리/패배 결과 화면

@onready var panel: PanelContainer = $Center/VBox/Panel
@onready var result_label: Label = $Center/VBox/Panel/Margin/VBox/ResultLabel
@onready var restart_button: Button = $Center/VBox/RestartButton

func _ready() -> void:
	visible = false
	add_to_group("result_overlay")
	if panel:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.1, 0.15, 0.85)
		style.set_corner_radius_all(16)
		style.set_content_margin_all(24)
		panel.add_theme_stylebox_override("panel", style)

func show_result(result_text: String) -> void:
	result_label.text = result_text
	visible = true
	GameState.game_over = true

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
