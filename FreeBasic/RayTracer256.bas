'320x240	  391,   409,   410,   393,   389

#include "vec3.bas"

#define WID 320
#define HEI 240
#define FOV 1.05' 60 degrees field of view in radians
#define FPS 60

#define max(a, b) iif((a) > (b), (a), (b))
#define min(a, b) iif((a) < (b), (a), (b))
#define floor(a) int(a)
#define ceil(a) (-int(-a))

dim time_start as integer = timer * 1000

const OUT_SIZE = WID * HEI
const TIME_STEP = 1000 / FPS

screen 14, 32' 320*240*32

type Material
  refractive_index as double
  albedo(3) as double
  diffuse_color as vec3
  specular_exponent as double
end type

type Sphere
  center as vec3
  radius as double
  material as Material
end type

type ret_scene
  hit as integer
  point as vec3
  N as vec3
  material as Material
end type

type ret_sphere
  hit as integer
  dist as double
end type

dim as Material      ivory = (1.0, {0.9,  0.5, 0.1, 0.0}, (0.4, 0.4, 0.3),   50.)
dim as Material      glass = (1.5, {0.0,  0.9, 0.1, 0.8}, (0.6, 0.7, 0.8),  125.)
dim as Material red_rubber = (1.0, {1.4,  0.3, 0.0, 0.0}, (0.3, 0.1, 0.1),   10.)
dim as Material     mirror = (1.0, {0.0, 16.0, 0.8, 0.0}, (1.0, 1.0, 1.0), 1425.)
dim shared as Material        mat = (1.0, {2.0,  0.0, 0.0, 0.0}, (0.0, 0.0, 0.0),    0.)' global
dim shared as Material  mat_white = (1.0, {2.0,  0.0, 0.0, 0.0}, (0.3, 0.3, 0.3),    0.)' global
dim shared as Material mat_orange = (1.0, {2.0,  0.0, 0.0, 0.0}, (0.3, 0.2, 0.1),    0.)' global

dim shared spheres(3) as Sphere
spheres(0) = type((-3,    0,   -16), 2,      ivory)
spheres(1) = type((-1.0, -1.5, -12), 2,      glass)
spheres(2) = type(( 1.5, -0.5, -18), 3, red_rubber)
spheres(3) = type(( 7,    5,   -18), 4,     mirror)

dim shared lights(2) as vec3  = {_
  (-20, 20,  20),_
  ( 30, 50, -25),_
  ( 30, 20,  30)_
}

function reflect(byref I as vec3, byref N as vec3) as vec3
  return I - N*2.0 * (I*N)
end function

function refract(byref I as vec3, byval N as vec3, byref eta_t as double, byref eta_i as double = 1.0) as vec3' Snell's law
  dim cosi as double = -max(-1.0, min(1.0, I*N))
  if cosi<0 then' If the ray comes from the inside the Object, swap the air And the media
    return refract(I, -N, eta_i, eta_t)
  end if
  dim eta as double = eta_i / eta_t
  dim k as double = 1 - eta*eta*(1 - cosi*cosi)
  if k<0 then
    return type(1,0,0)
  else
    return I*eta + N*(eta*cosi - sqr(k))' k<0 = total reflection, no ray to refract. I refract it anyways, this has no physical meaning
  end if
end function

function ray_sphere_intersect(byref orig as vec3, byref di as vec3, byref s as sphere) as ret_sphere' ret value is a pair [intersection found, distance]
  dim ret as ret_sphere
  ret.hit = false
  ret.dist = 0
	
  dim L as vec3 = s.center - orig
  dim tca as double = L * di
  dim d2 as double = L*L - tca*tca
  if d2 > s.radius*s.radius then return ret
  dim thc as double = sqr(s.radius*s.radius - d2)
  dim t0 as double = tca-thc
  dim t1 as double = tca+thc
  if t0>.001 then' offset the original point by .001 To avoid occlusion by the Object itself
    ret.hit = true
    ret.dist = t0
    return ret
  end if
  if t1>.001 then
    ret.hit = true
    ret.dist = t1
    return ret
  end if
	
  return ret
end function

function scene_intersect(byref orig as vec3, byref di as vec3) as ret_scene
  dim ret as ret_scene
  ret.material = mat

  dim nearest_dist as double = 1e10

  if abs(di.y)>.001 then' intersect the ray with the checkerboard, avoid division by zero
    dim d as double = -(orig.y+4)/di.y' the checkerboard plane has equation y = -4
    dim p as vec3 = orig + (di * d)
    if d>.001 and d<nearest_dist and abs(p.x)<10 and p.z<-10 and p.z>-30 then
      nearest_dist = d
      ret.point = p
      ret.N.y = 1
      ret.material = iif((floor(0.5*ret.point.x+1000) + floor(0.5*ret.point.z)) and 1, mat_orange, mat_white)
    end if
  end if

  for i as integer = 0 to ubound(spheres)' intersect the ray with all spheres
    dim sphere as ret_sphere = ray_sphere_intersect(orig, di, spheres(i))
    if sphere.hit=false OR sphere.dist > nearest_dist then continue for
    nearest_dist = sphere.dist
    ret.point = orig+(di*nearest_dist)
    ret.N = (ret.point - spheres(i).center).normalized()
    ret.material = spheres(i).material
  next

  ret.hit = nearest_dist<1000

  return ret
end function

function cast_ray(byref orig as vec3, byref di as vec3, byref depth as integer = 0) as vec3
  dim scene as ret_scene = scene_intersect(orig, di)

  if (depth>4) or (scene.hit=false) then
    return type(.2, .7, .8)' background color
  end if

  dim reflect_dir as vec3 = reflect(di, scene.N).normalized()
  dim refract_dir as vec3 = refract(di, scene.N, scene.material.refractive_index).normalized()
  dim reflect_color as vec3 = cast_ray(scene.point, reflect_dir, depth + 1)
  dim refract_color as vec3 = cast_ray(scene.point, refract_dir, depth + 1)

  dim diffuse_light_intensity as double = 0
  dim specular_light_intensity as double = 0

  for i as integer = 0 to ubound(lights)' checking If the point lies in the shadow of the light
    dim light_dir as vec3 = type(lights(i) - scene.point).normalized
    dim shadow as ret_scene = scene_intersect(scene.point, light_dir)
    if shadow.hit and (shadow.point - scene.point).norm < (lights(i) - scene.point).norm then continue for
    diffuse_light_intensity += max(0.0, light_dir * scene.N)
    specular_light_intensity += max(0.0, -reflect(-light_dir, scene.N)*di) ^ scene.material.specular_exponent
  next

  dim f1 as double = diffuse_light_intensity * scene.material.albedo(0)
  dim f2 as double = specular_light_intensity * scene.material.albedo(1)
  dim v1 as vec3 = scene.material.diffuse_color * f1
  dim v2 as vec3 = type(f2, f2, f2)
  dim v3 as vec3 = reflect_color * scene.material.albedo(2)
  dim v4 as vec3 = refract_color * scene.material.albedo(3)

  return (v1 + v2 + v3 + v4)
end function

dim framebuffer(OUT_SIZE) as vec3
dim img as any ptr = ImageCreate(WID, HEI)
if img = 0 then end -1

dim as byte stage = 0
dim as long pix = 0
dim as vec3 zero
dim as integer xx,yy
dim as integer time_end
dim as string label1 = "your score is and always has been"

do
  dim t as integer = timer * 1000

  select case as const stage
    case 0
      dim as double dir_z = -HEI/(2*tan(FOV/2))
      do while pix<OUT_SIZE' actual rendering loop
        dim as double dir_x = (pix mod WID + 0.5) -  WID/2
        dim as double dir_y = -(pix\WID + 0.5) + HEI/2' this flips the image at the same time
        dim as vec3 vec = type(dir_x, dir_y, dir_z).normalized
        framebuffer(pix) = cast_ray(zero, vec)
        pix += 1
        if timer * 1000 - t > TIME_STEP then
          cls
          draw string(0,10), pix & "/" & OUT_SIZE
          goto break
        end if
      loop
      pix = 0
      stage += 1
    case 1
      do while pix<OUT_SIZE
        dim as double mx = max(1.0, max(framebuffer(pix).x, max(framebuffer(pix).y, framebuffer(pix).z)))
        pset img, (xx,yy), rgb(255*framebuffer(pix).x/mx, 255*framebuffer(pix).y/mx, 255*framebuffer(pix).z/mx)
        pix += 1
        xx += 1
        if xx=WID then xx=0: yy+=1
        if timer * 1000 - t > TIME_STEP then
          cls
          draw string(0,10), pix & "/" & OUT_SIZE
          goto break
        end if
      loop
      pix = 0
      stage += 1
      time_end = timer * 1000 - time_start
    case 2
      put(0,0), img, pset
      stage += 1
      draw string(0,0), label1
      draw string(0,10), "" & time_end
    case else
  end select

break:
loop until inkey = chr(27)'ESC

ImageDestroy img
