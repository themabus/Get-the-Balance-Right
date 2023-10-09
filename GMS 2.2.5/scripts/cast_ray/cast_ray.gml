/// @description cast_ray(orig, dir[, depth])
/// @param orig
/// @param dir
/// @param depth
var orig = argument[0];
var dir = argument[1];
var dep = 0;
if (argument_count>2) dep = argument[2];

var tmp = scene_intersect(orig, dir);
var hit = tmp[0]; var point = tmp[1]; var N = tmp[2]; var material = tmp[3]; tmp = 0;

if (dep>4 || !hit)
    return array(0.2, 0.7, 0.8); // background color

var reflect_dir = vec3_normalized(reflect(dir, N));
var refract_dir = vec3_normalized(refract(dir, N, material.refractive_index));
var reflect_color = cast_ray(point, reflect_dir, dep + 1);
var refract_color = cast_ray(point, refract_dir, dep + 1);

var diffuse_light_intensity = 0;
var specular_light_intensity = 0;

for (var i=0; i<array_length_1d(lights); i++) {// checking if the point lies in the shadow of the light
    var light = lights[i];
    var light_dir = vec3_sub(light, point); light_dir = vec3_normalized(light_dir);
    var tmp = scene_intersect(point, light_dir);
    var hit = tmp[0]; var shadow_pt = tmp[1]; tmp = 0;
	var tmp1 = vec3_sub(shadow_pt,point);
    var tmp2 = vec3_sub(light,point);
    if ( hit && point_distance_3d(0,0,0, tmp1[v.x],tmp1[v.y],tmp1[v.z]) < point_distance_3d(0,0,0, tmp2[v.x],tmp2[v.y],tmp2[v.z]) ) continue;
    diffuse_light_intensity  += max(0., dot_product_3d(light_dir[v.x],light_dir[v.y],light_dir[v.z], N[v.x],N[v.y],N[v.z]));
	var tmp = vec3_inv( reflect(vec3_inv(light_dir), N) );
    specular_light_intensity += power(max(0., dot_product_3d(tmp[v.x],tmp[v.y],tmp[v.z], dir[v.x],dir[v.y],dir[v.z])), material.specular_exponent);
}

var tmp1 = vec3_scale(material.diffuse_color, diffuse_light_intensity * material.albedo[0]);
var tmp2 = specular_light_intensity * material.albedo[1];
tmp2 = array(tmp2, tmp2, tmp2);
var tmp3 = vec3_scale(reflect_color, material.albedo[2]);
var tmp4 = vec3_scale(refract_color, material.albedo[3]);

return vec3_add(vec3_add(vec3_add(tmp1, tmp2), tmp3), tmp4);