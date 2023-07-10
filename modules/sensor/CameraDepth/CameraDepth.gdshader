// Used with compute shader (see ComputeDepth.glsl in the same folder) 
shader_type spatial;
render_mode unshaded;

uniform sampler2D depth_texture : hint_depth_texture;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

const float maximum_distance = 1000.0f;
	
void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	vec3 val;

	if(linear_depth >= maximum_distance) 
	{
		// Set as maximum distance interpret as (255,255,255) => will be interpreted as INFINITE distance in compute shader.
		val = vec3(1.0, 1.0, 1.0); // white
	}
	else 
	{
		// parsing rule explaination : linear_depth = abc.def m 
		// split ab / cd / ef and store as 0.ab, 0.cd, 0.ef in each albedo channel 
		float residual_y; float residual_z;
		residual_y = modf(linear_depth/10.0f, val.x); val.x /= 100.0f; //0~99 => 0~0.99
		val.z = modf(residual_y*100.0f, val.y); val.y /= 100.0f; 		
	}

	ALBEDO = mix(pow((val + vec3(0.055)) * (1.0 / (1.0 + 0.055)), vec3(2.4)), val * (1.0 / 12.92), lessThan(val, vec3(0.04045)));
}
