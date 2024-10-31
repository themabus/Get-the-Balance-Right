type vec3
  as double x,y,z
  declare function norm as double
  declare function normalized as vec3
end type


operator - (byref v as vec3) as vec3
  return type(-v.x, -v.y, -v.z)
end operator

operator - (byref a as vec3, byref b as vec3) as vec3
  return type(a.x-b.x, a.y-b.y, a.z-b.z)
end operator

operator + (byref a as vec3, byref b as vec3) as vec3
  return type(a.x+b.x, a.y+b.y, a.z+b.z)
end operator

operator * (byref a as vec3, byref b as vec3) as double
  return a.x*b.x + a.y*b.y + a.z*b.z
end operator

operator * (byref v as vec3, byref n as double) as vec3
  return type(v.x*n, v.y*n, v.z*n)
end operator
operator * (byref n as double, byref v as vec3) as vec3
  return type(v.x*n, v.y*n, v.z*n)
end operator

function vec3.norm as double
  return sqr(x*x + y*y + z*z)
end function

function vec3.normalized as vec3
  return this * (1.0 / this.norm)
end function
