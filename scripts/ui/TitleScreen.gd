extends Control
## TitleScreen - 게임 시작 화면, 자동 연출 후 Press Any Key

const SUN_POS := Vector2(960, 180)
const SUN_RADIUS := 48.0
const MOON_RADIUS := 50.0
# 달 = SunNode 자식, 로컬 좌표 (태양 중심 = 0,0)
const MOON_START := Vector2(-120, 40)   # 가까이서 시작 → 흰 화면 유지시간 단축
const MOON_BEZIER_CTRL := Vector2(-60, 15)
const MOON_END := Vector2.ZERO

var intro_done: bool = false
var _blink_tween: Tween = null

@onready var bg_rect: ColorRect = $BgRect
@onready var eclipse_layer: Control = $EclipseLayer
@onready var sun_node: Node2D = $EclipseLayer/SunNode
@onready var moon_node: Node2D = $EclipseLayer/SunNode/MoonNode
@onready var logo_layer: Control = $LogoLayer
@onready var logo_image: TextureRect = $LogoLayer/LogoImage
@onready var press_any_key: Label = $PressAnyKey

func _ready() -> void:
	_apply_fonts()
	_setup_initial_state()
	_start_intro()

func _process(_delta: float) -> void:
	var dist: float = moon_node.position.length()
	# 달→태양 거리 (moon은 SunNode 자식이므로 length = 거리)
	var moon_radius: float = 52.0

	# cover_ratio: 태양을 가리는 비율 (배경·달 투명도용)
	var cover_ratio: float = clamp(1.0 - (dist / (SUN_RADIUS + MOON_RADIUS)), 0.0, 1.0)
	moon_node.modulate.a = cover_ratio
	bg_rect.color = Color(1.0 - cover_ratio, 1.0 - cover_ratio, 1.0 - cover_ratio, 1.0)

	# 로고: 초반엔 배경색과 동일(안 보임), 가리는 정도에 맞춰 검정→흰색
	if cover_ratio < 0.3:
		logo_image.modulate = bg_rect.color
	else:
		var logo_t: float = (cover_ratio - 0.3) / 0.7
		logo_image.modulate = Color(logo_t, logo_t, logo_t, 1.0)

	# cover_offset: 거리 400px↑ → 초승달, 0px → 보름달
	var crescent_ratio: float = clampf(dist / 400.0, 0.0, 1.0)
	moon_node.cover_offset = crescent_ratio * (moon_radius * 2.0)
	moon_node.mask_color = bg_rect.color
	moon_node.queue_redraw()

func _apply_fonts() -> void:
	var bebas: Font = _load_font("res://assets/fonts/BebasNeue-Regular.ttf")
	if bebas and press_any_key:
		press_any_key.add_theme_font_override("font", bebas)
	if press_any_key:
		press_any_key.add_theme_constant_override("letter_spacing", 6)

func _load_font(path: String) -> Font:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Font

func _moon_bezier_position(t: float) -> void:
	var u: float = 1.0 - t
	var pos: Vector2 = u * u * MOON_START + 2.0 * u * t * MOON_BEZIER_CTRL + t * t * MOON_END
	moon_node.position = pos

func _setup_initial_state() -> void:
	bg_rect.color = Color(1, 1, 1, 1)
	eclipse_layer.modulate.a = 1.0
	sun_node.modulate.a = 1.0
	sun_node.position = SUN_POS
	moon_node.position = MOON_START
	moon_node.modulate.a = 0.0
	logo_layer.modulate.a = 1.0
	logo_image.modulate = Color(1, 1, 1, 1.0)
	press_any_key.modulate.a = 0.0

func _start_intro() -> void:
	var tween := create_tween()
	tween.set_parallel(false)

	# 0.0s: 게임 시작 시 이미 태양 발광 중, 달 이동 시작 (베지어 곡선, 총 5.0초) - 부드럽고 완만한 궤적
	tween.tween_callback(func() -> void:
		moon_node.position = MOON_START
		var moon_tween := create_tween()
		moon_tween.tween_method(_moon_bezier_position, 0.0, 1.0, 5.0).set_ease(Tween.EASE_IN_OUT)
	)
	tween.tween_interval(5.0)

	# 5.0s: 개기월식 완성 → moon 확정
	tween.tween_callback(func() -> void:
		moon_node.modulate.a = 1.0
	)
	tween.tween_interval(2.0)

	# 7.0s: Press Any Key 깜빡임 시작 + intro_done
	tween.tween_callback(func() -> void:
		intro_done = true
		press_any_key.modulate.a = 1.0
		_start_press_blink()
	)

func _start_press_blink() -> void:
	if _blink_tween and _blink_tween.is_running():
		_blink_tween.kill()
	_blink_tween = create_tween()
	_blink_tween.set_loops()
	_blink_tween.tween_property(press_any_key, "modulate:a", 0.2, 0.6).set_ease(Tween.EASE_IN_OUT)
	_blink_tween.tween_property(press_any_key, "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_IN_OUT)

func _input(event: InputEvent) -> void:
	# 숫자 1: 계기월식 타이틀 스킵
	if event is InputEventKey:
		var ke := event as InputEventKey
		if ke.pressed and not ke.echo:
			if ke.keycode == KEY_1 or ke.keycode == KEY_KP_1:
				get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
				accept_event()
				return
	if not intro_done:
		return
	if event is InputEventKey or event is InputEventMouseButton:
		if event is InputEventKey:
			var ke := event as InputEventKey
			if not ke.pressed or ke.echo:
				return
		elif event is InputEventMouseButton:
			var mb := event as InputEventMouseButton
			if not mb.pressed:
				return
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
