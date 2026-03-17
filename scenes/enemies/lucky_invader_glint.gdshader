shader_type canvas_item;

uniform float time;
uniform vec4 base_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 glint_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float hframes = 1.0;
uniform float vframes = 1.0;

uniform float band_width : hint_range(0.01, 1.0) = 0.4;
uniform float sharpness : hint_range(0.001, 0.2) = 0.02;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	if (time < 0.0) {
        COLOR = vec4(base_color.rgb * tex.a, tex.a);
    } else {
	    vec2 frame_size = 1.0 / vec2(hframes, vframes);
	    vec2 local_uv = mod(UV, frame_size) / frame_size;
	    
	    float dist = local_uv.x + local_uv.y;
	    
	    // Sharp, wide band logic
	    float edge_low = time - band_width;
	    float edge_high = time + band_width;
	    
	    float glint = smoothstep(edge_low, edge_low + sharpness, dist) - 
	                  smoothstep(edge_high - sharpness, edge_high, dist);
	    
	    vec3 final_rgb = mix(base_color.rgb, glint_color.rgb, glint * 0.8);
	    
	    COLOR = vec4(final_rgb * tex.a, tex.a);
	}
}