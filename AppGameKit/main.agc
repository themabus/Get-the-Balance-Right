`320x240	48841, 47870, 48590, 49970, 50851

SetErrorMode(2) `show all errors

global width = 320
global height = 240
global fov# = 1.05 `60 degrees field of view in radians

global time_start: time_start = timer()
`Print("Go!")

#constant out_size 76800 `width * height
#constant D2R 57.2957795130 `180/Pi
global fps = 60
global time_step#: time_step# = 1.0 / 60.0

type Material
	refractive_index#
	albedo as float[]
	diffuse_color `vec3
	specular_exponent
endtype

type Sphere
	center `vec3
	radius#
	material as Material
endtype

type ret_scene
	hit
	point `vec3
	N `vec3
	material as Material
endtype

type ret_sphere
	hit
	dist#
endtype

global framebuffer as integer[out_size]
global out as integer[out_size]

global lights as integer[2]
global spheres as Sphere[3]

` materials --->
global mat as Material
mat.refractive_index# = 1.0
mat.albedo = [2.0, 0.0, 0.0, 0.0]
mat.diffuse_color = CreateVector3()
mat.specular_exponent = 0

global mat_white as Material
mat_white.refractive_index# = 1.0
mat_white.albedo = [2.0, 0.0, 0.0, 0.0]
mat_white.diffuse_color = CreateVector3(0.3, 0.3, 0.3)
mat_white.specular_exponent = 0

global mat_orange as Material
mat_orange.refractive_index# = 1.0
mat_orange.albedo = [2.0, 0.0, 0.0, 0.0]
mat_orange.diffuse_color = CreateVector3(0.3, 0.2, 0.1)
mat_orange.specular_exponent = 0

ivory as Material
ivory.refractive_index# = 1.0
ivory.albedo = [0.9, 0.5, 0.1, 0.0]
ivory.diffuse_color = CreateVector3(0.4, 0.4, 0.3)
ivory.specular_exponent = 50.0

glass as Material
glass.refractive_index# = 1.5
glass.albedo = [0.0, 0.9, 0.1, 0.8]
glass.diffuse_color = CreateVector3(0.6, 0.7, 0.8)
glass.specular_exponent = 125.0

red_rubber as Material
red_rubber.refractive_index# = 1.0
red_rubber.albedo = [1.4, 0.3, 0.0, 0.0]
red_rubber.diffuse_color = CreateVector3(0.3, 0.1, 0.1)
red_rubber.specular_exponent = 10.0

mirror as Material
mirror.refractive_index# = 1.0
mirror.albedo = [0.0, 16.0, 0.8, 0.0]
mirror.diffuse_color = CreateVector3(1.0, 1.0, 1.0)
mirror.specular_exponent = 1425.0
` <--- materials

` spheres --->
spheres[0].center = CreateVector3(-3, 0, -16)
spheres[0].radius# = 2.0
spheres[0].material = ivory

spheres[1].center = CreateVector3(-1.0, -1.5, -12)
spheres[1].radius# = 2.0
spheres[1].material = glass

spheres[2].center = CreateVector3(1.5, -0.5, -18)
spheres[2].radius# = 3.0
spheres[2].material = red_rubber

spheres[3].center = CreateVector3(7, 5, -18)
spheres[3].radius# = 4.0
spheres[3].material = mirror
` <--- spheres

` lights --->
lights[0] = CreateVector3(-20,20,20)
lights[1] = CreateVector3(30,50,-25)
lights[2] = CreateVector3(30,20,30)
` <--- lights

global stage = 0
global pix = 0

SetWindowTitle( "RayTracer256" )
SetWindowSize( width, height, 0 )
SetWindowAllowResize( 0 ) `allow the user to resize the window
SetVirtualResolution( width, height ) `doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) `allow both portrait and landscape on mobile devices
SetSyncRate( fps, 0 ) `30fps instead of 60 to save battery
SetScissor( 0,0,0,0 ) `use the maximum available screen space, no black borders
UseNewDefaultFonts( 1 ) `since version 2.0.22 we can use nicer default fonts
global imb: imb = CreateImageMemblock(1, width, height)
global zero: zero = CreateVector3()
global bail = 0
global fs = 0
global time_end
global label1$ = "your score is and always has been"
CreateSprite(1,1)


repeat
    input()
	process()
`	Sync()
	Render2DFront(): swap()
until bail


function process()
	t = timer()

	select stage
		case 0
			dir_z# = -height/(2.0*Tan(D2R*fov#/2.0)) `Const
			while pix < out_size `actual rendering loop
				dir_x# = (mod(pix, width) + 0.5) - width/2.0
				dir_y# = -(pix/width + 0.5) + height/2.0 `this flips the image at the same time
				v0 = CreateVector3(dir_x#,dir_y#,dir_z#)
				v1 = vec3_normalized(v0)
				framebuffer[pix] = cast_ray( zero, v1, 0 )
				DeleteVector3(v0) `cleanup
				DeleteVector3(v1) `cleanup
				inc pix
				if timer() - t > time_step#
					print("")
					print( str(pix) +"/" + str(out_size) )
					exitfunction
				endif
			endwhile
			print("")
			print( str(pix) +"/" + str(out_size) )
			pix = 0
			inc stage
		endcase
		case 1 `unneccesary loops left in deliberately
			while pix < out_size
				mx# = max(1.0, max(GetVector3X(framebuffer[pix]), max(GetVector3Y(framebuffer[pix]), GetVector3Z(framebuffer[pix]))))
				out[pix] = (255 << 24) + (floor(255*GetVector3Z(framebuffer[pix])/mx#) << 16) + (floor(255*GetVector3Y(framebuffer[pix])/mx#) << 8) + floor(255*GetVector3X(framebuffer[pix])/mx#)
				DeleteVector3(framebuffer[pix]) `cleanup
				inc pix
				if timer() - t > time_step#
					print("")
					print( str(out_size) +"/" + str(out_size) )
					exitfunction
				endif
			endwhile
			framebuffer.length = -1
			print("")
			print( str(out_size) +"/" + str(out_size) )
			pix = 0
			inc stage
			time_end = (timer() - time_start) * 1000
		endcase
		case 2
			for i=0 to height-1
				for j=0 to width-1
					dot(j,i, out[pix])
					inc pix
				next
			next
			out.length = -1
			CreateImageFromMemblock(1,imb)
			SetImageMinFilter(1,0)
			SetImageMagFilter(1,0)
			pix = 0
			inc stage
		endcase
		case default
			print(label1$)
			print(time_end)
		endcase
	endselect
endfunction


function cast_ray(orig, dir, depth)
	scene as ret_scene: scene = scene_intersect(orig, dir)
	
	if (depth>4) or (scene.hit=0)
		DeleteVector3(scene.point) `cleanup
		DeleteVector3(scene.N) `cleanup
		ret = CreateVector3(.2, .7, .8)` background color
		exitfunction ret
	endif
	
	v1 = reflect(dir, scene.N)
	reflect_dir = vec3_normalized(v1)
	v2 = refract(dir, scene.N, scene.material.refractive_index#, 1.0)
	refract_dir = vec3_normalized(v2)
	DeleteVector3(v1) `cleanup
	DeleteVector3(v2) `cleanup
	reflect_color = cast_ray(scene.point, reflect_dir, depth + 1)
	refract_color = cast_ray(scene.point, refract_dir, depth + 1)
	
	diffuse_light_intensity# = 0
	specular_light_intensity# = 0
	
	for i=0 to lights.length `checking If the point lies in the shadow of the light
		v1 = vec3_sub(lights[i], scene.point)
		light_dir = vec3_normalized(v1)
		DeleteVector3(v1) `cleanup
		shadow as ret_scene: shadow = scene_intersect(scene.point, light_dir)
		v1 = vec3_sub(shadow.point, scene.point)
		v2 = vec3_sub(lights[i], scene.point)
		if shadow.hit<>0 and GetVector3Length(v1) < GetVector3Length(v2) then goto cont
		diffuse_light_intensity# = diffuse_light_intensity# + max(0.0, GetVector3Dot(light_dir, scene.N))
		v3 = vec3_inv(light_dir)
		v4 = reflect(v3, scene.N)
		v0 = vec3_inv(v4)
		specular_light_intensity# = specular_light_intensity# + max(0.0, GetVector3Dot(v0, dir)) ^ scene.material.specular_exponent
		DeleteVector3(v3) `cleanup
		DeleteVector3(v4) `cleanup
		DeleteVector3(v0) `cleanup
		cont:
		DeleteVector3(shadow.point) `cleanup
		DeleteVector3(shadow.N) `cleanup
		DeleteVector3(light_dir) `cleanup
		DeleteVector3(v1) `cleanup
		DeleteVector3(v2) `cleanup
	next
	
	f1# = diffuse_light_intensity# * scene.material.albedo[0]
	f2# = specular_light_intensity# * scene.material.albedo[1]
	v1 = vec3_scale(scene.material.diffuse_color, f1#)
	v2 = CreateVector3(f2#, f2#, f2#)
	v3 = vec3_scale(reflect_color, scene.material.albedo[2])
	v4 = vec3_scale(refract_color, scene.material.albedo[3])
	DeleteVector3(scene.point) `cleanup
	DeleteVector3(scene.N) `cleanup
	v0 = vec3_add(v1, v2)
	DeleteVector3(v1) `cleanup
	DeleteVector3(v2) `cleanup
	v1 = vec3_add(v0, v3)
	DeleteVector3(v0) `cleanup
	DeleteVector3(v3) `cleanup
	ret = vec3_add(v1, v4)
	DeleteVector3(v1) `cleanup
	DeleteVector3(v4) `cleanup
	DeleteVector3(reflect_dir) `cleanup
	DeleteVector3(refract_dir) `cleanup
	DeleteVector3(reflect_color) `cleanup
	DeleteVector3(refract_color) `cleanup
	
endfunction ret

function scene_intersect(orig, dir)
	ret as ret_scene
	ret.material = mat
	ret.point = CreateVector3()
	ret.N = CreateVector3()
	
	nearest_dist# = 10000000000 `1e10
	if abs(GetVector3Y(dir))>.001 `intersect the ray with the checkerboard, avoid division by zero
		d# = -(GetVector3Y(orig)+4)/GetVector3Y(dir) `the checkerboard plane has equation y = -4
		v0 = vec3_scale(dir, d#)
		p = vec3_add(orig, v0)
		DeleteVector3(v0) `cleanup
		If d#>.001 and d#<nearest_dist# and abs(GetVector3X(p))<10 and GetVector3Z(p)<-10 and GetVector3Z(p)>-30
			nearest_dist# = d#
			DeleteVector3(ret.point) `cleanup
			ret.point = p
			SetVector3(ret.N, 0,1,0)
			If ( floor(0.5*GetVector3X(ret.point)+1000) + floor(0.5*GetVector3Z(ret.point)) ) && 1 then ret.material = mat_orange else ret.material = mat_white
		else
			DeleteVector3(p) `cleanup
		endif
	endif
	
	for i=0 to spheres.length `intersect the ray with all spheres
		sphere as ret_sphere: sphere = ray_sphere_intersect(orig, dir, spheres[i])
		if sphere.hit=0 or sphere.dist# > nearest_dist# then continue
		nearest_dist# = sphere.dist#
		DeleteVector3(ret.point) `cleanup
		v0 = vec3_scale(dir, nearest_dist#)
		ret.point = vec3_add(orig, v0)
		DeleteVector3(v0) `cleanup
		DeleteVector3(ret.N) `cleanup
		v0 = vec3_sub(ret.point, spheres[i].center)
		ret.N = vec3_normalized(v0)
		DeleteVector3(v0) `cleanup
		ret.material = spheres[i].material
	next
	
	ret.hit = nearest_dist#<1000
	
endfunction ret

function ray_sphere_intersect(orig, dir, s as sphere) `ret value is a pair [intersection found, distance]
	ret as ret_sphere
	ret.hit = 0
	ret.dist# = 0
	
	L = vec3_sub(s.center, orig)
	tca# = GetVector3Dot(L,dir)
	d2# = GetVector3Dot(L,L) - tca#*tca#
	DeleteVector3(L) `cleanup
	if d2# > s.radius#*s.radius# then exitfunction ret
	thc# = sqrt(s.radius#*s.radius# - d2#)
	t0# = tca#-thc#
	t1# = tca#+thc#
	If t0#>.001 `offset the original point by .001 to avoid occlusion by the object itself
		ret.hit = 1
		ret.dist# = t0#
		exitfunction ret
	endif
	if t1#>.001
		ret.hit = 1
		ret.dist# = t1#
		exitfunction ret
	endif
endfunction ret

function reflect(I, N)
	v0 = vec3_scale(N, 2.0 * GetVector3Dot(I,N))
	ret = vec3_sub(I, v0)
	DeleteVector3(v0) `cleanup
endfunction ret

function refract(I, N, eta_t#, eta_i#) `Snell's law
	cosi# = -max(-1.0, min(1.0, GetVector3Dot(I,N)))
	if cosi#<0 `if the ray comes from the inside the object, swap the air and the media
		v0 = vec3_inv(N)
		ret = refract(I, v0, eta_i#, eta_t#)
		DeleteVector3(v0) `cleanup
		exitfunction ret
	endif
	eta# = eta_i# / eta_t#
	k# = 1 - eta#*eta#*(1 - cosi#*cosi#)
	if k#<0
		ret = CreateVector3(1,0,0)
		exitfunction ret
	else
		v0 = vec3_scale(I, eta#)
		v1 = vec3_scale(N, (eta#*cosi# - sqrt(k#)))
		ret = vec3_add(v0, v1)
		DeleteVector3(v0) `cleanup
		DeleteVector3(v1) `cleanup
		exitfunction ret `k<0 = total reflection, no ray to refract. I refract it anyways, this has no physical meaning
	endif
endfunction -1


//////////////////////////////////////////////////////////////////////////////// vec3
function vec3_normalized(v)
	l# = getVector3Length(v)
	x# = GetVector3X(v)/l#
	y# = GetVector3Y(v)/l#
	z# = GetVector3Z(v)/l#
	ret = CreateVector3(x#,y#,z#)
endfunction ret

function vec3_scale(v, n#)
	ret = CreateVector3(GetVector3X(v)*n#, GetVector3Y(v)*n#, GetVector3Z(v)*n#)
endfunction ret

function vec3_add(a, b)
	ret = CreateVector3(GetVector3X(a)+GetVector3X(b), GetVector3Y(a)+GetVector3Y(b), GetVector3Z(a)+GetVector3Z(b))
endfunction ret

function vec3_sub(a, b)
	ret = CreateVector3(GetVector3X(a)-GetVector3X(b), GetVector3Y(a)-GetVector3Y(b), GetVector3Z(a)-GetVector3Z(b))
endfunction ret

function vec3_inv(v)
	ret = CreateVector3(-GetVector3X(v), -GetVector3Y(v), -GetVector3Z(v))
endfunction ret


//////////////////////////////////////////////////////////////////////////////// min/max
function min(a#,b#)
	if a# < b# then ret# = a# else ret# = b#
endfunction ret#

function max(a#,b#)
	if a# > b# then ret# = a# else ret# = b#
endfunction ret#


//////////////////////////////////////////////////////////////////////////////// input
function input()
	if GetRawKeyState(27) `Esc
		bail = 1
	endif
	if GetRawKeyState(261) or GetRawKeyState(262) `AltL / AltR
		if GetRawKeyState(115) `F4
			bail = 1
		elseif GetRawKeyPressed(13) `Enter
			fs = not fs
			if fs 
				SetWindowSize(GetMaxDeviceWidth(), GetMaxDeviceHeight(), 1)
			else 
				SetWindowSize(width, height, 0)
			endif
		endif
	endif
endfunction


//////////////////////////////////////////////////////////////////////////////// dot on a surface
function CreateImageMemblock(id, w,h)
	imb = CreateMemblock(12 + (4 * w*h))
	SetMemblockInt(imb,0,w)
	SetMemblockInt(imb,4,h)
	SetMemblockInt(imb,8,32)
	CreateImageFromMemblock(id,imb)
endfunction imb

function dot(x,y, rgba)
	offset = 12 + (4*(x + (y*GetMemblockInt(imb,0))))
	SetMemblockInt(imb,offset,rgba)
endfunction
