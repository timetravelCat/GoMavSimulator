shader_type canvas_item;

uniform float alpha = 0.3;

void fragment() {
	// Place fragment code here.
	COLOR.w = alpha;
}
