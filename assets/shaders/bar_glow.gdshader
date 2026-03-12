shader_type canvas_item;

render_mode blend_add;

uniform vec4 color_gray : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 color_glow : source_color = vec4(0.95, 0.9, 0.3, 1.0);
uniform float spread : hint_range(0.0, 1.0) = 0.0;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	float center = 0.5;
	float dist_v = abs(UV.y - center) * 2.0;
	float inner = spread * 0.3;
	float glow_mask = 1.0 - smoothstep(inner, spread + 0.02, dist_v);
	float glow_core = glow_mask * intensity;
	vec2 uv_norm = UV - vec2(0.5, 0.5);
	float dist_r = length(uv_norm) * 2.5;
	float halo = 1.0 - smoothstep(0.0, 1.6, dist_r);
	float glow_emissive = glow_core * (0.8 + 0.6 * halo);
	COLOR = mix(vec4(0.0, 0.0, 0.0, 0.0), color_glow, glow_emissive);
}
