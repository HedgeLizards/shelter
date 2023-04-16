shader_type spatial;
render_mode unshaded, world_vertex_coords;

#include "simplex.gdshaderinc"


varying vec3 core_off;


void vertex() {
	core_off = VERTEX - NODE_POSITION_WORLD;
}

float lsq2(vec2 v){
	return v.x*v.x + v.y*v.y;
}

void fragment() {
// 	fnl_state noise = fnlCreateState(1);
// 	noise.octaves = 3;
// 	float centerdist = 1.0-2.0*abs(UV.x - 0.5);
// 	float o = fnlGetNoise3D(noise, core_off.x*200.0, core_off.z*200.0, core_off.y*200.0-TIME*100.0);
	vec4 ni = vec4(core_off.xz * 2.0, core_off.y*1.0 - TIME*2.0, TIME*0.5);
	float o = (snoise(ni)*0.6 + snoise(ni*2.0)*0.3 + snoise(ni*4.0)*0.1);
	float brightness = clamp((o +0.5 - core_off.y*0.4) -lsq2(core_off.xz), 0, 1);
	float n = brightness;
	ALBEDO = vec3(3.0*n, 4.0*n*n*n, 0.2*n*n*n*n);
	if (n < 0.1) {
		discard;
	}
// 	ALPHA = clamp(n*10.0, 0, 1);
}
