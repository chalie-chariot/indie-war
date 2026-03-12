extends Control
## 스킬 버튼 - 원형, 호버 시 하얀 광원 글로우

var key: String = "Q"
var is_selected: bool = false
signal pressed(key: String)
signal hovered(key: String)
signal unhovered(key: String)

const BTN_RADIUS: float = 30.0
const GLOW_MAX_RADIUS: float = 60.0
const BTN_SIZE: int = 136  # 글로우(60) 포함한 컨트롤 크기, 칼자름 방지
const SEGMENTS: int = 36  # 각도 분할 (파장 다양성)
const RINGS: int = 10    # 반경 분할
var _label: Label
var _hide_label: bool = false
var _glow_intensity: float = 0.0
var _glow_spread: float = 0.0  # 0~1, 첫 호버 시 팍 퍼지는 정도
var _glow_tween: Tween = null
var _spread_tween: Tween = null

func _ready() -> void:
	custom_minimum_size = Vector2(BTN_SIZE, BTN_SIZE)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	if not _hide_label:
		_label = Label.new()
		_label.text = key
		_label.set_anchors_preset(Control.PRESET_FULL_RECT)
		var pad: int = int((BTN_SIZE - 64) / 2.0)
		_label.offset_left = pad
		_label.offset_top = pad
		_label.offset_right = BTN_SIZE - pad
		_label.offset_bottom = BTN_SIZE - pad
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_label.add_theme_font_size_override("font_size", 28)
		_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_label)

func setup(k: String, hide_label: bool = false) -> void:
	key = k
	_hide_label = hide_label

func _process(_delta: float) -> void:
	if _glow_intensity > 0.001 or _glow_spread > 0.001:
		queue_redraw()

func _draw() -> void:
	var center: Vector2 = size * 0.5
	var border_alpha: float = 1.0 if is_selected else 0.8
	# 첫 호버: 팍 퍼진 다음 파장 일렁임
	if _glow_intensity > 0.001:
		var time: float = Time.get_ticks_msec() * 0.001
		var spread: float = (GLOW_MAX_RADIUS - BTN_RADIUS) * _glow_spread
		var ang_step: float = TAU / float(SEGMENTS)
		var rad_step: float = spread / float(RINGS) if RINGS > 0 else 0.0
		# 파장: spread 0.4~0.95 구간에서 smoothstep으로 부드럽게 페이드 인 (끊김 방지)
		var x: float = clampf((_glow_spread - 0.4) / 0.55, 0.0, 1.0)
		var wave_scale: float = x * x * (3.0 - 2.0 * x)
		for ri in range(RINGS):
			var r_inner: float = BTN_RADIUS + ri * rad_step
			var r_outer: float = BTN_RADIUS + (ri + 1) * rad_step
			var t_mid: float = (float(ri) + 0.5) / float(RINGS)
			var center_boost: float = 1.0 - 0.75 * t_mid
			var edge_fade: float = 1.0 - 0.4 * clampf((t_mid - 0.6) / 0.4, 0.0, 1.0)  # 외곽 40% 부드럽게 페이드
			var base_a: float = 0.65 * center_boost * edge_fade * _glow_intensity * _glow_spread
			for si in range(SEGMENTS):
				var ang: float = si * ang_step
				var wave: float = wave_scale * (0.4 * sin(ang * 2.3 + time * 3.5) + 0.3 * sin(ang * 4.1 - time * 2.2) + 0.2 * sin(ri * 0.8 + time * 4.0))
				var a: float = base_a * (1.0 + wave)
				var th0: float = ang
				var th1: float = ang + ang_step
				# 파장에 맞춰 반경이 원반하게 곡선으로 들쑥날쑥 (부드러운 sin 곡선)
				var rad_wave0: float = 1.0 + wave_scale * (0.12 * sin(ang * 2.5 + time * 2.2) + 0.08 * sin(ang * 4.2 - time * 1.5))
				var rad_wave1: float = 1.0 + wave_scale * (0.12 * sin((ang + ang_step) * 2.5 + time * 2.2) + 0.08 * sin((ang + ang_step) * 4.2 - time * 1.5))
				var pts: PackedVector2Array = [
					center + Vector2(cos(th0), sin(th0)) * r_inner * rad_wave0,
					center + Vector2(cos(th0), sin(th0)) * r_outer * rad_wave0,
					center + Vector2(cos(th1), sin(th1)) * r_outer * rad_wave1,
					center + Vector2(cos(th1), sin(th1)) * r_inner * rad_wave1
				]
				draw_colored_polygon(pts, Color(1, 1, 1, clampf(a, 0, 1)))
	# 클릭(고정) 시 하얀색으로 꽉 채움, 평소엔 어두운 원
	if is_selected:
		draw_circle(center, BTN_RADIUS, Color(1, 1, 1, 1))
		draw_arc(center, BTN_RADIUS, 0, TAU, 64, Color(0.9, 0.9, 0.9, 1), 1.5)
	else:
		draw_circle(center, BTN_RADIUS, Color(0.15, 0.15, 0.15, 1))
		draw_arc(center, BTN_RADIUS, 0, TAU, 64, Color(1, 1, 1, border_alpha), 2.0)

func _set_glow_intensity(v: float) -> void:
	_glow_intensity = clampf(v, 0, 1)
	if _glow_intensity <= 0.001 and _glow_spread <= 0.001:
		set_process(false)
	queue_redraw()

func _set_glow_spread(v: float) -> void:
	_glow_spread = clampf(v, 0, 1)
	queue_redraw()

func _on_mouse_entered() -> void:
	hovered.emit(key)
	if _glow_tween:
		_glow_tween.kill()
	if _spread_tween:
		_spread_tween.kill()
	_glow_intensity = 1.0
	_glow_spread = 0.0
	set_process(true)
	# 1단계: 빛 팍 퍼짐 (0.18초)
	_spread_tween = create_tween()
	_spread_tween.tween_method(_set_glow_spread, 0.0, 1.0, 0.18).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	queue_redraw()

func _on_mouse_exited() -> void:
	unhovered.emit(key)
	if _glow_tween:
		_glow_tween.kill()
	if _spread_tween:
		_spread_tween.kill()
	_glow_spread = 1.0
	set_process(true)
	_glow_tween = create_tween()
	_glow_tween.tween_method(_set_glow_intensity, 1.0, 0.0, 1.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit(key)
		accept_event()
