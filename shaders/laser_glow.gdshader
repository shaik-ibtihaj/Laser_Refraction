shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float intensity : hint_range(0.5, 5.0) = 2.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = tex_color * glow_color * intensity;
}
