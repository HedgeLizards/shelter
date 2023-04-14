shader_type sky;

uniform sampler2D star_tex;
uniform vec3 sun_color : source_color;

float rand_from_seed(in uint seed) {
	int k;
	int s = int(seed);
	if (s == 0) {
		s = 305420679;
	}
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0){
		s += 2147483647;
	}
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

void sky() {
	vec2 skypos = EYEDIR.xz / abs(EYEDIR.y);
	vec3 base_color = vec3(0,0,0);
	//float stardist = clamp(1.0-distance(fract(skypos * 8.0), vec2(0.5, 0.5))*32.0, 0.0, 1.0);
	//base_color = mix(base_color, vec3(1.0, 1.0, 1.0), stardist);
	base_color = texture(star_tex, skypos).xyz;
	float vh = 0.3;
	float sundist = (dot(normalize(vec3(EYEDIR.x*vh, EYEDIR.y, EYEDIR.z*vh)), vec3(0.0, 0.0, 1.0))-0.5)*2.0;
	COLOR = mix(base_color,sun_color, clamp(sundist, 0.0, 1.0));
}
