shader_type fog;

#include "simplex.gdshaderinc"


uniform vec3 color : source_color;
uniform vec3 emission : source_color;

void fog() {
	vec4 ni = vec4((WORLD_POSITION+ vec3(0, 0, TIME*15.0))/40.0, 1.0);
	float no = (snoise(ni)*0.6 + snoise(ni*2.0)*0.3 + snoise(ni*4.0)*0.1);
	DENSITY = clamp(no / 5.0 + 0.03 - pow(WORLD_POSITION.y,2)/240000.0, 0, 0.2);
	ALBEDO = color;
	EMISSION = emission;
}
