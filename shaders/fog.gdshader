shader_type fog;

uniform vec3 color : source_color;
uniform vec3 emission : source_color;

void fog() {
	DENSITY = 0.1;
	ALBEDO = color;
}
