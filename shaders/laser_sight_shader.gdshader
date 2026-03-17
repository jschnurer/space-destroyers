shader_type canvas_item;

uniform float dash_length = 20.0;
uniform float gap_length = 20.0;
uniform float scroll_offset = 0.0;

void fragment() {
    float local_y = abs(VERTEX.y);
    float pattern = mod(local_y + scroll_offset, dash_length + gap_length);
    if (pattern > dash_length) {
        discard;
    }
    COLOR = vec4(1.0, 0.2, 0.2, 0.75);
}