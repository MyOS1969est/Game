shader_type spatial;
render_mode cull_disabled, diffuse_burley;

uniform vec4 leaf_dark : source_color = vec4(0.18, 0.29, 0.10, 1.0);
uniform vec4 leaf_light : source_color = vec4(0.37, 0.49, 0.18, 1.0);
uniform float breeze_time = 0.0;
varying vec3 leaf_world;

void vertex() {
	leaf_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float tip = UV.y * UV.y * COLOR.g;
	VERTEX.x += sin(breeze_time * 1.4 + leaf_world.x * 1.9 + leaf_world.z) * tip * 0.028;
	VERTEX.z += cos(breeze_time * 0.9 + leaf_world.z * 2.0) * tip * 0.018;
}

void fragment() {
	if (!FRONT_FACING) { NORMAL = -NORMAL; }
	float across = abs(UV.x - 0.5) * 2.0;
	float midrib = 1.0 - smoothstep(0.018, 0.05, across);
	float vein = 1.0 - smoothstep(0.015, 0.055, abs(fract(UV.y * 10.0 - across * 0.43) - 0.5));
	float tone = 0.30 + sin(UV.y * PI) * 0.32 + (1.0 - across) * 0.16;
	vec3 color = mix(leaf_dark.rgb, leaf_light.rgb, tone);
	color = mix(color, leaf_light.rgb, midrib * 0.48 + vein * 0.10);
	ALBEDO = color;
	ROUGHNESS = 0.65 + across * 0.14;
	SPECULAR = 0.30;
	BACKLIGHT = color * 0.25;
}
