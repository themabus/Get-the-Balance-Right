/// @description ray_sphere_intersect(orig, dir, sphere)
/// @param orig
/// @param dir
/// @param sphere
function ray_sphere_intersect(argument0, argument1, argument2) {
	var orig = argument0;
	var dir = argument1;
	var s = argument2;
	// ret value is a pair [intersection found, distance]
	var L = vec3_sub(s.center, orig);
	var tca = dot_product_3d(L[v.x],L[v.y],L[v.z], dir[v.x],dir[v.y],dir[v.z]);//float
	var d2 = dot_product_3d(L[v.x],L[v.y],L[v.z], L[v.x],L[v.y],L[v.z]) - tca*tca;//float

	if (d2 > s.radius*s.radius) return array(false, 0);

	var thc = sqrt(abs(s.radius*s.radius - d2));//float
	var t0 = tca-thc;//float
	var t1 = tca+thc;//float

	if (t0>.001) return array(true, t0);// offset the original point by .001 to avoid occlusion by the object itself
	if (t1>.001) return array(true, t1);

	return array(false, 0);



}
