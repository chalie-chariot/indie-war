shader_type canvas_item;

uniform float light_pos : hint_range(-0.5, 1.5) = -0.3;

void fragment() {
	// UV.x 0~1: 좌→우
	// 양 끝 20% 페이드 (바깥선, 중간선)
	float edge_fade = smoothstep(0.0, 0.2, UV.x) * smoothstep(1.0, 0.8, UV.x);
	// 중앙 40% 구간 강조 (핵심선)
	float center_fade = sin(UV.x * PI);  // 중앙 1, 끝 0
	// 글로우: light_pos 중심 가우시안
	float glow = exp(-pow((UV.x - light_pos) * 6.0, 2.0));

	// UV.y 0.5 = 세로 중앙, 높이 비율로 레이어 (80px 기준)
	float dy = abs(UV.y - 0.5);

	// 바깥 글로우선: 6px (3px each) = 3/80 ≈ 0.0375
	float outer = 1.0 - smoothstep(0.03, 0.06, dy);
	float outer_alpha = 0.08 * edge_fade * outer;

	// 중간 선: 2px (1px each) = 0.0125
	float mid = 1.0 - smoothstep(0.008, 0.02, dy);
	float mid_alpha = 0.20 * edge_fade * mid;

	// 중앙 핵심선: 1px, 60%, 중앙 40% 구간만 (x 0.3~0.7)
	float core = 1.0 - smoothstep(0.0, 0.015, dy);
	float core_fade = smoothstep(0.2, 0.4, UV.x) * smoothstep(0.8, 0.6, UV.x);
	float core_alpha = 0.60 * core_fade * core;

	float base_alpha = max(max(outer_alpha, mid_alpha), core_alpha);
	float glow_alpha = glow * 0.8;

	COLOR = vec4(1.0, 1.0, 1.0, base_alpha + glow_alpha);
}
