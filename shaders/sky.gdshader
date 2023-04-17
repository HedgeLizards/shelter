shader_type sky;

uniform sampler2D star_tex;
uniform vec3 sun_color : source_color;
uniform vec3 moon_position;

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

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

const float sectionSize = 0.02;
void sky() {
	vec2 skypos = EYEDIR.xz / abs(EYEDIR.y);
// 	vec3 base_color = vec3(0,0,0);
	//float stardist = clamp(1.0-distance(fract(skypos * 8.0), vec2(0.5, 0.5))*32.0, 0.0, 1.0);
	//base_color = mix(base_color, vec3(1.0, 1.0, 1.0), stardist);
	vec3 sectionStart = round(EYEDIR / sectionSize);
	uvec3 sectionId = floatBitsToUint(sectionStart);
	uint seed = hash(sectionId.x + hash(sectionId.y + hash(sectionId.z)));
	vec3 star_offset = vec3(
		rand_from_seed(seed),
		rand_from_seed(seed * 59u + 73u),
		rand_from_seed(seed * 73u + 37u)
	);
	vec3 star_pos = (sectionStart + star_offset) * sectionSize;
	float star_distance = distance(EYEDIR, star_pos);
	float star_brightness = clamp(1.0-star_distance*500.0, 0, 1);
	vec3 base_color = vec3(star_brightness);//texture(star_tex, skypos/2.0).xyz;
//	base_color = mix(base_color, vec
	vec3 moon_color = vec3(1,1,1);
	float moon_distance = (dot(EYEDIR, normalize(moon_position))-0.9995)*10000.0;
	COLOR = mix(base_color, moon_color, clamp(moon_distance, 0, 1));
	//float vh = 0.3;
	//float sundist = (dot(normalize(vec3(EYEDIR.x*vh, EYEDIR.y, EYEDIR.z*vh)), vec3(0.0, 0.0, 1.0))-0.5)*2.0;
	//COLOR = mix(base_color,sun_color, clamp(sundist, 0.0, 1.0));
}
