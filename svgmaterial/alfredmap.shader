shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D base_palette;
uniform sampler2D new_palette;

float find_color_in_base_palette(in vec4 color, float pal_size, float pixel_size) {
    for(float x = 0.0; x <= pal_size; x += pixel_size)   {      
        vec4 pal_col = texture(base_palette, vec2(x, 0.0));

        if(pal_col.rgba == color.rgba) {
            return x;
        }
    }

    return -1.0;
}

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    ivec2 size = textureSize(base_palette, 0);
    float pos = find_color_in_base_palette(color, float(size.x), TEXTURE_PIXEL_SIZE.x); 

    // We found the position of the color in the base palette, so fetch a new color from the new palette
    if(pos != -1.0) {
        COLOR = texture(new_palette, vec2(pos, 0.0));
    }
    // The color is not in the base palette, so we don't know its position. Keep the base color.
    else {
        COLOR = color;
    }   
}