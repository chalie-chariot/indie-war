extends HBoxContainer
## [검은원] [왼쪽라인] [계승전] [오른쪽라인] [검은원] - 라인 2개, 빛 이동, 텍스트와 겹치지 않음

const ANIM_DURATION: float = 0.3

var _light_pos: float = -1.0  # 0~1 (0~0.5=왼쪽라인, 0.5~1=오른쪽라인), -1=빛 없음
var _tween: Tween = null

@onready var line_left: Control = $LineLeft
@onready var line_right: Control = $LineRight

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if _tween and _tween.is_running():
		_update_line_lights()

func _update_line_light(line: Control, pos: float) -> void:
	if line and line.has_method("set") and "light_pos" in line:
		line.set("light_pos", pos)
		line.queue_redraw()

func _update_line_lights() -> void:
	if _light_pos < 0:
		_update_line_light(line_left, -1.0)
		_update_line_light(line_right, -1.0)
		return
	if _light_pos <= 0.5:
		_update_line_light(line_left, _light_pos * 2.0)
		_update_line_light(line_right, -1.0)
	else:
		_update_line_light(line_left, 1.0)
		_update_line_light(line_right, (_light_pos - 0.5) * 2.0)

func animate_left_to_right() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	_light_pos = 0.0
	_update_line_lights()
	_tween = create_tween()
	_tween.tween_property(self, "_light_pos", 1.0, ANIM_DURATION).set_ease(Tween.EASE_IN_OUT)

func animate_right_to_left() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	_light_pos = 1.0
	_update_line_lights()
	_tween = create_tween()
	_tween.tween_property(self, "_light_pos", 0.0, ANIM_DURATION).set_ease(Tween.EASE_IN_OUT)
