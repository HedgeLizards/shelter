shader_type canvas_item;
uniform float health;

void fragment() {
	vec2 de = clamp(abs(UV * 2. - 1.)-clamp(health, 0, 1),0,1);
	COLOR = vec4(1,0,0,sqrt(de.x*de.x + de.y*de.y)/2. );
}
