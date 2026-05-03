shader_type canvas_item;

uniform float shadow_intensity : hint_range(0.0, 1.0) = 0.0;
// -1 for left, 1 for right, 0 for no shadow.
uniform int shadow_side = 0;
// Number of steps for shadow.
uniform float shadow_steps = 3.0;

// damage flash color
uniform vec4 flash_color: source_color = vec4(0.0, 0.0, 0.0, 0.0);

// shield outline
uniform float shield_thickness = 0;
// shield color
uniform vec4 shield_color: source_color = vec4(0,0,0,0);

void handle_flash(sampler2D base_tex, vec2 base_uv, inout vec4 current_color) {
	vec4 tex = texture(base_tex, base_uv);
    current_color = vec4(flash_color.rgb * tex.a, tex.a);
}

void handle_shield(vec2 texture_pixel_size, sampler2D base_tex, vec2 base_uv, inout vec4 current_color) {
	vec2 size = texture_pixel_size * shield_thickness;
	float outline = 0.0;
	
	// Check neighboring pixels in a circle
	for (float i = -1.0; i <= 1.0; i += 1.0) {
		for (float j = -1.0; j <= 1.0; j += 1.0) {
			vec2 offset = vec2(i, j) * size;
			outline += texture(base_tex, base_uv + offset).a;
		}
	}
	
	vec4 color = texture(base_tex, base_uv);
	// If the current pixel is transparent but neighbors aren't, apply outline
	if (color.a <= 0.0 && outline > 0.0) {
		current_color = shield_color; //vec4(shield_color.rgb, clamp(outline, 0.0, 1.0));
	} else {
		current_color = color;
	}
}

void fragment() {
	if (flash_color.a < 0.0001) {
		handle_flash(TEXTURE, UV, COLOR);
	} else if (shadow_side != 0) {
		int pixel_side = UV.x < 0.5 ? -1 : 1;
		
		if (pixel_side == shadow_side) {
			vec4 tex_color = texture(TEXTURE, UV);
			float percent_from_center = abs(UV.x - 0.5) * 2.0;
			float stepped_intensity = ceil(percent_from_center * shadow_steps) / shadow_steps;
			float final_reduction = stepped_intensity * shadow_intensity;
			tex_color.rgb *= (1.0 - clamp(final_reduction, 0.0, 1.0));
			COLOR = tex_color;
		}
	}
	
	handle_shield(TEXTURE_PIXEL_SIZE, TEXTURE, UV, COLOR);
}
