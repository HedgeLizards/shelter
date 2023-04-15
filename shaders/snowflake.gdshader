shader_type spatial;
render_mode cull_disabled, world_vertex_coords;

uniform vec3 cave_pos;
uniform float cave_radius;

varying float inside;

void vertex() {
	inside = distance(VERTEX, cave_pos) < cave_radius ? 1.0 : 0.0;
}

void fragment() {
	if (inside > 0.1) {
		discard;
	} 
}
