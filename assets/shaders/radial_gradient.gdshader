shader_type canvas_item;

uniform vec4 center_color : source_color = vec4(1.0, 1.0, 1.0, 0.05);
uniform vec4 edge_color : source_color = vec4(1.0, 1.0, 1.0, 0.0);

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(UV, center) / 0.707;
	COLOR = mix(center_color, edge_color, dist);
}
