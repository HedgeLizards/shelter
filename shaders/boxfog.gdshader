shader_type spatial;
render_mode cull_front, world_vertex_coords;

#include "simplex.gdshaderinc"

uniform vec3 color : source_color;

void fragment() {
	
	vec4 ni = vec4((VERTEX+ vec3(0, 0, TIME*15.0))/40.0, 1.0);
	float no = (snoise(ni)*0.6 + snoise(ni*2.0)*0.3 + snoise(ni*4.0)*0.1);
	ALPHA = clamp((no + 1.0)/2.0, 0.0, 1.0);
	ALBEDO = color;
}
void light() {
	DIFFUSE_LIGHT += ATTENUATION * ALBEDO*0.1;
}