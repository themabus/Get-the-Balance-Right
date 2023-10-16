import "mod_math";

type vec3
    float x,y,z;
end

function float vec3_dot(vec3 a, vec3 b)
begin
    return a.x*b.x + a.y*b.y + a.z*b.z;
end

function vec3_scale(vec3 v, float n, vec3 pointer ret)
begin
    ret.x = v.x * n;
    ret.y = v.y * n;
    ret.z = v.z * n;
end

function float vec3_norm(vec3 v)
begin
    return sqrt(v.x*v.x + v.y*v.y + v.z*v.z);
end

function vec3_normalized(vec3 v, vec3 pointer ret)
begin
    vec3_scale(v, 1.0 / vec3_norm(v), ret);
end

function vec3_add(vec3 a, vec3 b, vec3 pointer ret)
begin
    ret.x = a.x + b.x;
    ret.y = a.y + b.y;
    ret.z = a.z + b.z;
end

function vec3_sub(vec3 a, vec3 b, vec3 pointer ret)
begin
    ret.x = a.x - b.x;
    ret.y = a.y - b.y;
    ret.z = a.z - b.z;
end

function vec3_inv(vec3 v, vec3 pointer ret)
begin
    ret.x = -v.x;
    ret.y = -v.y;
    ret.z = -v.z;
end