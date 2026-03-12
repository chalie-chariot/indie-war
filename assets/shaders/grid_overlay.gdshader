shader_type canvas_item;

uniform vec4 grid_color : source_color = vec4(0.91, 0.78, 0.29, 0.03);  // #e8c84a 3%
uniform float grid_spacing : hint_range(1.0, 128.0) = 48.0;
uniform float line_width : hint_range(0.5, 4.0) = 1.0;

void fragment() {
	vec2 grid_pos = mod(FRAGCOORD.xy, grid_spacing);
	float line = step(grid_spacing - line_width, grid_pos.x) + step(grid_spacing - line_width, grid_pos.y);
	line = min(line, 1.0);
	COLOR = vec4(grid_color.rgb, grid_color.a * line);
}
