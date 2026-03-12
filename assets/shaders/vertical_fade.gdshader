shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform vec4 bottom_color : source_color = vec4(0.118, 0.118, 0.118, 1.0);

void fragment() {
	## 위(UV.y=0)=투명(캐릭터 선명), 아래(UV.y=1)=불투명(페이드)
	COLOR = mix(top_color, bottom_color, UV.y);
}
