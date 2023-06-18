shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0);
uniform float speed = 4.0;
uniform float size : hint_range(0.01, 1.0, 0.01) = 0.02;
uniform float progress : hint_range(0.01, 1.0) = 0.0;

void fragment() {
	float shine = step(1.0 - size * 0.5, 0.5 + 0.5 * sin(UV.x - UV.y + progress * speed));
	COLOR.rgb = mix(COLOR.rgb, color.rgb, shine * color.a);
}
