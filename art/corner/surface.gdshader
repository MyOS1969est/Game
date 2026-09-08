shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.76, 0.74, 0.64, 1.0);
uniform vec4 worn_color : source_color = vec4(0.57, 0.56, 0.47, 1.0);
uniform sampler2D surface_noise : repeat_enable, filter_linear_mipmap;
uniform float roughness : hint_range(0.0, 1.0) = 0.7;
uniform float roughness_variation = 0.18;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float grain_scale = 2.6;
uniform float relief_depth = 0.005;
uniform float mottling = 0.12;
uniform float wear_amount = 0.0;
uniform float glaze = 0.0;
uniform float occlusion_strength = 0.7;
varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

float triplanar_noise(vec3 p, vec3 weights) {
	return texture(surface_noise, p.yz).r * weights.x
		+ texture(surface_noise, p.xz).r * weights.y
		+ texture(surface_noise, p.xy).r * weights.z;
}

void fragment() {
	vec3 weights = pow(abs(world_normal), vec3(4.0));
	weights /= max(dot(weights, vec3(1.0)), 0.0001);
	float broad = triplanar_noise(world_position * 0.11, weights);
	float grain = triplanar_noise(world_position * grain_scale, weights);
	float wear = smoothstep(0.66, 0.81, grain * 0.6 + broad * 0.4) * wear_amount;
	float instance_shade = fract(sin(dot(NODE_POSITION_WORLD.xz, vec2(12.9898, 78.233))) * 43758.5453);
	vec3 color = mix(base_color.rgb, worn_color.rgb, wear);
	color *= 1.0 + (broad - 0.5) * mottling + (grain - 0.5) * mottling * 0.32;
	color *= 0.975 + instance_shade * 0.05;
	ALBEDO = color;
	ROUGHNESS = clamp(roughness + (grain - 0.5) * roughness_variation + wear * 0.12, 0.14, 0.99);
	METALLIC = metallic;
	SPECULAR = 0.5;
	CLEARCOAT = glaze;
	CLEARCOAT_ROUGHNESS = 0.35;
	AO = mix(1.0, COLOR.r, occlusion_strength);
	AO_LIGHT_AFFECT = 0.23;
	// Surface-gradient bump mapping works with the exported UVs and also with
	// older scene meshes. Detail is procedural material data, not concept pixels.
	float height = grain * 0.75 + broad * 0.25;
	vec3 dpdx = dFdx(VERTEX);
	vec3 dpdy = dFdy(VERTEX);
	vec3 r1 = cross(dpdy, NORMAL);
	vec3 r2 = cross(NORMAL, dpdx);
	float determinant = dot(dpdx, r1);
	vec3 gradient = sign(determinant) * (dFdx(height) * r1 + dFdy(height) * r2);
	NORMAL = normalize(max(abs(determinant), 0.0000001) * NORMAL - relief_depth * gradient);
}
