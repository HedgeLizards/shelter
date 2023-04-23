shader_type canvas_item;
uniform float health;
uniform float time;
const uint hit_count = 6u;
uniform vec3[hit_count] hits;

float dist_sqr(vec2 a) {
	return a.x * a.x + a.y * a.y;
}

void fragment() {
	vec2 st = SCREEN_UV;
	float aspect_ratio = SCREEN_PIXEL_SIZE.y/SCREEN_PIXEL_SIZE.x;
	vec2 scaled_st = (st -vec2(0.0, 0.5)) / vec2(1.0, aspect_ratio) + vec2(0,0.5); 
	vec2 de = clamp(abs(UV * 2. - 1.)-clamp(health, 0, 1),0,1);
	float alpha = sqrt(de.x*de.x + de.y*de.y)/2.;
	for (uint i=0u; i<hit_count; ++i) {
		alpha = max(alpha, 1. + hits[i].z - time -  dist_sqr(scaled_st - hits[i].xy) * 10.);
//		if (distance(UV, hits[i].xy) < 0.1) {
//			alpha = 1.0;
//		}
	}
	COLOR = vec4(1,0,0,alpha);
}
