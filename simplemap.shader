shader_type canvas_item;

uniform vec4 target = vec4(0.0,0.0,0.0,1.0);
uniform vec4 new_color = vec4(0.3,0.3,0.3,1.0);

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (COLOR == target) {
		COLOR = new_color;
	}	
}