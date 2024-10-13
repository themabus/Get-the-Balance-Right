/// @description scene_intersect(orig, dir)
/// @param orig
/// @param dir
function scene_intersect(argument0, argument1) {
	var orig = argument0;
	var dir = argument1;

	var N = array(0,0,0);
	var pt = array(0,0,0);
	var material = mat;

	var nearest_dist = 10000000000;//1e10

	if (abs(dir[v.y])>.001) { // intersect the ray with the checkerboard, avoid division by zero
	    var d = -(orig[v.y]+4)/dir[v.y]; // the checkerboard plane has equation y = -4
	    var p = vec3_add(orig, vec3_scale(dir, d));
	    if (d>.001 && d<nearest_dist && abs(p[v.x])<10 && p[v.z]<-10 && p[v.z]>-30) {
	        nearest_dist = d;
	        var pt = p;
	        var N = array(0,1,0);
	        if ((floor(.5*pt[v.x]+1000) + floor(.5*pt[v.z])) & 1) material = mat_orange else material = mat_white;
	    }
	}

	for (var i=0; i<array_length_1d(spheres); i++) {// intersect the ray with all spheres
	    var s = spheres[i];
	    var tmp = ray_sphere_intersect(orig, dir, s);
	    var intersection = tmp[0]; var d = tmp[1]; tmp = 0;
	    if (!intersection || d > nearest_dist) continue;
	    nearest_dist = d;
	    pt = vec3_add(orig, vec3_scale(dir, nearest_dist));
	    N = vec3_sub(pt, s.center); N = vec3_normalized(N);
	    material = s.material;
	}

	return array( nearest_dist<1000, pt, N, material );



}
