shader_type spatial;
render_mode cull_disabled, unshaded;

#include "fastnoiselite.gdshaderinc"

void fragment() {

	fnl_state noise = fnlCreateState(1);
	float centerdist = 1.0-2.0*abs(UV.x - 0.5);
	float brightness = clamp((fnlGetNoise3D(noise, UV.x*200.0, UV.y*200.0+TIME*100.0, TIME*20.0) -0.5 + UV.y*1.5)*centerdist*centerdist, 0, 1);
	float n = brightness;
	ALBEDO = vec3(3.0*n, 4.0*n*n*n, 0.2*n*n*n*n);
	ALPHA = clamp(n*10.0, 0, 1);
}
