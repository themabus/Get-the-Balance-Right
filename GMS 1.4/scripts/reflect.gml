///reflect(I, N)
var I = argument0;
var N = argument1;

var tmp = 2.*dot_product_3d(I[v.x],I[v.y],I[v.z], N[v.x],N[v.y],N[v.z]);

return vec3_sub( I, vec3_scale(N, tmp) )
