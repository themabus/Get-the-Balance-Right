/// @description vec3_normalized(vec3)
/// @param vec3
function vec3_normalized(argument0) {
	var vec = argument0;
	var xx = vec[v.x];
	var yy = vec[v.y];
	var zz = vec[v.z];

	var norm = 1./point_distance_3d(0,0,0, xx,yy,zz);

	return vec3_scale(vec, norm)



}
