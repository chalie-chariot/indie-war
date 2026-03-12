shader_type canvas_item;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR.rgb = 1.0 - COLOR.rgb;
}
