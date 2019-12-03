shader_type canvas_item;

uniform vec4 target = vec4(0, 0.196078, 0.196078, 1.0);
uniform vec4 new_color = vec4(0.3,0.3,0.3,1.0);
uniform float delta = 0.001953125;


bool fuzzy_equality(in vec4 a, in vec4 b) {
	vec4 vdelta = vec4(delta, delta, delta, 0.0);
	return (all(lessThanEqual(b-a, vdelta)) && all(lessThanEqual(a-b, vdelta)));
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (fuzzy_equality(COLOR, target)) {
		COLOR = new_color;
	}	
}