shader_type canvas_item;

void fragment(){
	vec2 pixel = UV / TEXTURE_PIXEL_SIZE;
	int x_min = max(int(pixel.x-1.), 0);
	int x_max = min(int(pixel.x+2.), int(1./TEXTURE_PIXEL_SIZE.x));
	int y_min = max(int(pixel.y-1.), 0);
	int y_max = min(int(pixel.y+2.), int(1./TEXTURE_PIXEL_SIZE.y));
	vec4 total = vec4(0., 0., 0., 0.);
	for(int i = x_min; i < x_max; i++){
		for(int j = y_min; j < y_max; j++){
			total += texture(TEXTURE, vec2(float(i), float(j)) * TEXTURE_PIXEL_SIZE);
		}
	}
	total /= 9.;
	COLOR = total;
}