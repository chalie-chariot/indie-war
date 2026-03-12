shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.2, 0.4, 0.9);
uniform float glow_spread : hint_range(0.005, 0.06) = 0.017;
uniform float glow_intensity : hint_range(0.3, 2.0) = 0.98;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	// 1. Invert icon color (black -> white)
	vec3 inv_rgb = 1.0 - tex.rgb;
	
	// 2. Sample neighbors for outer glow halo (아까·지금 중간 정도)
	float halo = 0.0;
	float s1 = glow_spread;
	float s2 = glow_spread * 2.0;
	float s3 = glow_spread * 2.8;
	vec2 offsets[14] = vec2[](
		vec2(-s1, 0), vec2(s1, 0), vec2(0, -s1), vec2(0, s1),
		vec2(-s1, -s1), vec2(s1, -s1), vec2(-s1, s1), vec2(s1, s1),
		vec2(-s2, 0), vec2(s2, 0), vec2(0, -s2), vec2(0, s2),
		vec2(-s3, 0), vec2(0, s3)
	);
	for (int i = 0; i < 14; i++) {
		halo += texture(TEXTURE, UV + offsets[i]).a;
	}
	halo /= 14.0;
	float edge_glow = smoothstep(0.03, 0.48, halo) * (1.0 - tex.a) * glow_intensity;
	edge_glow = clamp(edge_glow, 0.0, 0.8);
	
	// 3. Icon base (inverted) + colored glow at edges
	vec3 final_rgb = mix(inv_rgb, glow_color.rgb, edge_glow * glow_color.a * 0.85);
	float final_a = max(tex.a, edge_glow * 0.65);
	COLOR = vec4(final_rgb, final_a);
}
