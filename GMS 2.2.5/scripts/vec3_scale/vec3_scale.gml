/// @description vec3_scale(vec3, n)
/// @param vec3
/// @param n
var vec = argument0;
var xx = vec[v.x];
var yy = vec[v.y];
var zz = vec[v.z];
var n = argument1;

return array(xx*n,yy*n,zz*n)
