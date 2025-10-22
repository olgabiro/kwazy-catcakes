shader_type canvas_item;

uniform float threshold : hint_range(0.9, 1.0, 0.001) = 0.99;
uniform float softness : hint_range(0.0, 0.2, 0.001) = 0.02;

void fragment() {
    vec4 c = texture(TEXTURE, UV);
    float luma = (c.r + c.g + c.b) / 3.0;
    float mask = smoothstep(threshold, threshold + softness, luma);
    float a = c.a * (1.0 - mask);
    COLOR = vec4(c.rgb, a);
}
