shader_type sky;

uniform sampler2D star_tex;
uniform vec3 sun_color : source_color;
uniform vec3 moon_position;


void sky() {
	vec2 skypos = EYEDIR.xz / abs(EYEDIR.y);
// 	vec3 base_color = vec3(0,0,0);
	//float stardist = clamp(1.0-distance(fract(skypos * 8.0), vec2(0.5, 0.5))*32.0, 0.0, 1.0);
	//base_color = mix(base_color, vec3(1.0, 1.0, 1.0), stardist);
	vec3 base_color = texture(star_tex, skypos).xyz;
	vec3 moon_color = vec3(1,1,1);
	float moon_distance = (dot(EYEDIR, normalize(moon_position))-0.9995)*10000.0;
	COLOR = mix(base_color, moon_color, clamp(moon_distance, 0, 1));
	//float vh = 0.3;
	//float sundist = (dot(normalize(vec3(EYEDIR.x*vh, EYEDIR.y, EYEDIR.z*vh)), vec3(0.0, 0.0, 1.0))-0.5)*2.0;
	//COLOR = mix(base_color,sun_color, clamp(sundist, 0.0, 1.0));
}
