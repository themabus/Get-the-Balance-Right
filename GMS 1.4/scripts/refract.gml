///refract(I, N, eta_t[, eta_i])
var I = argument[0];
var N = argument[1];
var eta_t = argument[2];
var eta_i = 1.0;
if (argument_count>3) eta_i = argument[3];

// Snell's law
var cosi = - max(-1., min(1., dot_product_3d(I[v.x],I[v.y],I[v.z], N[v.x],N[v.y],N[v.z])));//float
if (cosi<0) return refract(I, vec3_inv(N), eta_i, eta_t); // if the ray comes from the inside the object, swap the air and the media
var eta = eta_i / eta_t;//float
var k = 1 - eta*eta*(1 - cosi*cosi);//float

if (k<0)
    return array(1,0,0);// k<0 = total reflection, no ray to refract. I refract it anyways, this has no physical meaning
else {
    var tmp1 = vec3_scale(I, eta);
    var tmp2 = vec3_scale(N, eta*cosi - sqrt(k));
    return vec3_add(tmp1, tmp2);
}
