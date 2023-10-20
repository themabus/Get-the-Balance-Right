;320x240	 1213,  1215,  1226,  1223,  1217
;320x240	 1224,  1168,  1177,  1177,  1173	<-- no cleanup

Include "vec3.bb"

Global width# = 320
Global height# = 240
Global fov# = 1.05; 60 degrees field of view in radians

Global time_start = MilliSecs()
DebugLog "Go!"

fps = 60
Global D2R# = 180/Pi

Type material
	Field refractive_index#
	Field albedo#[3]
	Field diffuse_color.vec3
	Field specular_exponent#
End Type

Type sphere
	Field center.vec3
	Field radius#
	Field material.material
End Type

Type ret_scene
	Field hit
	Field point.vec3
	Field N.vec3
	Field material.material
End Type

Type ret_sphere
	Field hit
	Field dist#
End Type

Global out_size = width * height
Global time_step# = 1000.0 / fps

Dim framebuffer.vec3(out_size)
Dim out(out_size)

Dim lights.vec3(2)
Dim spheres.sphere(3)

; materials --->
Global mat.material = New material
mat\refractive_index = 1.0
mat\albedo[0] = 2
mat\diffuse_color = vec3()

Global mat_white.material = New material
mat_white\refractive_index = 1.0
mat_white\albedo[0] = 2
mat_white\diffuse_color = vec3(0.3, 0.3, 0.3)

Global mat_orange.material = New material
mat_orange\refractive_index = 1.0
mat_orange\albedo[0] = 2
mat_orange\diffuse_color = vec3(0.3, 0.2, 0.1)

ivory.material = New material
ivory\refractive_index = 1.0
ivory\albedo[0] = 0.9
ivory\albedo[1] = 0.5
ivory\albedo[2] = 0.1
ivory\albedo[3] = 0.0
ivory\diffuse_color = vec3(0.4, 0.4, 0.3)
ivory\specular_exponent = 50.0

glass.material = New material
glass\refractive_index = 1.5
glass\albedo[0] = 0.0
glass\albedo[1] = 0.9
glass\albedo[2] = 0.1
glass\albedo[3] = 0.8
glass\diffuse_color = vec3(0.6, 0.7, 0.8)
glass\specular_exponent = 125.0

red_rubber.material = New material
red_rubber\refractive_index = 1.0
red_rubber\albedo[0] = 1.4
red_rubber\albedo[1] = 0.3
red_rubber\albedo[2] = 0.0
red_rubber\albedo[3] = 0.0
red_rubber\diffuse_color = vec3(0.3, 0.1, 0.1)
red_rubber\specular_exponent = 10.0

mirror.material = New material
mirror\refractive_index = 1.0
mirror\albedo[0] = 0.0
mirror\albedo[1] = 16.0
mirror\albedo[2] = 0.8
mirror\albedo[3] = 0.0
mirror\diffuse_color = vec3(1.0, 1.0, 1.0)
mirror\specular_exponent = 1425.0
; <--- materials

; spheres --->
spheres(0) = New sphere
spheres(0)\center = vec3(-3, 0, -16)
spheres(0)\radius = 2.0
spheres(0)\material = ivory

spheres(1) = New sphere
spheres(1)\center = vec3(-1.0, -1.5, -12)
spheres(1)\radius = 2.0
spheres(1)\material = glass

spheres(2) = New sphere
spheres(2)\center = vec3(1.5, -0.5, -18)
spheres(2)\radius = 3.0
spheres(2)\material = red_rubber

spheres(3) = New sphere
spheres(3)\center = vec3(7, 5, -18)
spheres(3)\radius = 4.0
spheres(3)\material = mirror
; <--- spheres

; lights --->
lights(0) = vec3(-20,20,20)
lights(1) = vec3(30,50,-25)
lights(2) = vec3(30,20,30)
; <--- lights

Global stage = 0
Global pix = 0

Graphics width,height,32,2
Global zero.vec3 = vec3()
Global bail = False
Global fs = False
Global kbready = True
Global img = CreateImage(width,height)
Global time_end = 0
Global label1$ = "your score is and always has been"
AppTitle "RayTracer256"
fps_timer = CreateTimer(fps)
TFormFilter 0


While Not bail
	inkey()
	update()
	WaitTimer(fps_timer)
Wend


Function update()
	t = MilliSecs()

	Select stage
		Case 0
			dir_z# = -height/(2.0*Tan(D2R*fov/2.0)); Const
			While pix < out_size;  actual rendering loop
				dir_x# = (pix Mod width + 0.5) - width/2.0
				dir_y# = -(pix/width + 0.5) + height/2.0; this flips the image at the same time
				v0.vec3 = vec3(dir_x, dir_y, dir_z)
				v1.vec3 = vec3_normalized(v0)
				framebuffer(pix) = cast_ray(zero, v1)
				Delete v0; cleanup
				Delete v1; cleanup
				pix = pix + 1
				If MilliSecs() - t > time_step Then
					Cls
					Text 0,10,pix +"/" + out_size
					Return
				End If
			Wend
			Cls
			Text 0,10,pix +"/" + out_size
			pix = 0
			stage = stage + 1
		Case 1
			While pix < out_size
				mx# = Max(1., Max(framebuffer(pix)\x, Max(framebuffer(pix)\y, framebuffer(pix)\z)))
				out(pix) = (255*framebuffer(pix)\x/mx) Shl 16 + 255*framebuffer(pix)\y/mx Shl 8 + 255*framebuffer(pix)\z/mx
				Delete framebuffer(pix); cleanup
				pix = pix + 1
				If MilliSecs() - t > time_step Then
					Cls
					Text 0,10,out_size +"/" + out_size
					Return
				End If
			Wend
			Cls
			Text 0,10,out_size +"/" + out_size
			pix = 0
			stage = stage + 1
			time_end = MilliSecs() - time_start
			DebugLog time_end
		Case 2
			For i=0 To height-1
				For j=0 To width-1
					WritePixel j, i, out(pix), ImageBuffer(img)
					pix = pix + 1
				Next
			Next
			ScaleImage img, GraphicsWidth()/width, GraphicsHeight()/height
			pix = 0
			stage = stage + 1
		Default
			DrawBlock img, 0,0
			Text 0,0,label1
			Text 0,10,time_end
	End Select
End Function


Function cast_ray.vec3(orig.vec3, dir.vec3, depth = 0)
	scene.ret_scene = scene_intersect(orig, dir)
	
	If (depth>4) Or (scene\hit=0) Then
		Delete scene\point; cleanup
		Delete scene\N; cleanup
		Delete scene; cleanup
		Delete dir; cleanup
		Return vec3(.2, .7, .8); background color
	End If
	
	v1.vec3 = reflect(dir, scene\N)
	reflect_dir.vec3 = vec3_normalized(v1)
	v2.vec3 = refract(dir, scene\N, scene\material\refractive_index, 1.0)
	refract_dir.vec3 = vec3_normalized(v2)
	Delete v1; cleanup
	Delete v2; cleanup
	reflect_color.vec3 = cast_ray(scene\point, reflect_dir, depth + 1)
	refract_color.vec3 = cast_ray(scene\point, refract_dir, depth + 1)
	
	diffuse_light_intensity# = 0
	specular_light_intensity# = 0
	
	For i=0 To 2; checking if the point lies in the shadow of the light
		v1.vec3 = vec3_sub(lights(i), scene\point)
		light_dir.vec3 = vec3_normalized(v1)
		Delete v1; cleanup
		shadow.ret_scene = scene_intersect(scene\point, light_dir)
		v1.vec3 = vec3_sub(shadow\point, scene\point)
		v2.vec3 = vec3_sub(lights(i), scene\point)
		If shadow\hit<>0 And vec3_norm(v1) < vec3_norm(v2) Goto continue
		diffuse_light_intensity = diffuse_light_intensity + Max(0.0, vec3_dot(light_dir, scene\N))
		v3.vec3 = vec3_inv(light_dir)
		v4.vec3 = reflect(v3, scene\N)
		v0.vec3 = vec3_inv(v4)
		specular_light_intensity = specular_light_intensity + Max(0.0, vec3_dot(v0, dir)) ^ scene\material\specular_exponent
		.continue
		Delete shadow\point; cleanup
		Delete shadow\N; cleanup
		Delete shadow; cleanup
		Delete light_dir; cleanup
		Delete v1; cleanup
		Delete v2; cleanup
		Delete v3; cleanup
		Delete v4; cleanup
		Delete v0; cleanup
	Next

	f1# = diffuse_light_intensity * scene\material\albedo[0]
	f2# = specular_light_intensity * scene\material\albedo[1]
	v1.vec3 = vec3_scale(scene\material\diffuse_color, f1)
	v2.vec3 = vec3(f2, f2, f2)
	v3.vec3 = vec3_scale(reflect_color, scene\material\albedo[2])
	v4.vec3 = vec3_scale(refract_color, scene\material\albedo[3])
	Delete scene\point; cleanup
	Delete scene\N; cleanup
	Delete scene; cleanup
	v0.vec3 = vec3_add(v1, v2)
	Delete v1; cleanup
	Delete v2; cleanup
	v1.vec3 = vec3_add(v0, v3)
	Delete v0; cleanup
	Delete v3; cleanup
	ret.vec3 = vec3_add(v1, v4)
	Delete v1; cleanup
	Delete v4; cleanup
	Delete reflect_dir; cleanup
	Delete refract_dir; cleanup
	Delete reflect_color; cleanup
	Delete refract_color; cleanup
	
	Return ret
End Function


Function scene_intersect.ret_scene(orig.vec3, dir.vec3)
	ret.ret_scene = New ret_scene
	ret\material = mat
	ret\point = vec3()
	ret\N = vec3()
	
	nearest_dist# = 10000000000; 1e10
	If Abs(dir\y)>.001 Then ; intersect the ray with the checkerboard, avoid division by zero
		d# = -(orig\y+4)/dir\y ; the checkerboard plane has equation y = -4
		v0.vec3 = vec3_scale(dir, d)
		p.vec3 = vec3_add(orig, v0)
		Delete v0; cleanup
		If d>.001 And d<nearest_dist And Abs(p\x)<10 And p\z<-10 And p\z>-30 Then
			nearest_dist = d
			Delete ret\point; cleanup
			ret\point = p
			ret\N\y = 1
			If (Floor(0.5*ret\point\x+1000) + Floor(0.5*ret\point\z)) And 1 ret\material = mat_orange Else ret\material = mat_white
		Else
			Delete p; cleanup
		End If
	End If
	
	For i=0 To 3; intersect the ray with all spheres
		sphere.ret_sphere = ray_sphere_intersect(orig, dir, spheres(i))
		If sphere\hit=False Or sphere\dist > nearest_dist Goto continue
		nearest_dist = sphere\dist
		Delete ret\point; cleanup
		v0.vec3 = vec3_scale(dir, nearest_dist)
		ret\point = vec3_add(orig, v0)
		Delete v0; cleanup
		Delete ret\N; cleanup
		v0.vec3 = vec3_sub(ret\point, spheres(i)\center)
		ret\N = vec3_normalized(v0)
		Delete v0; cleanup
		ret\material = spheres(i)\material
		.continue
		Delete sphere; cleanup
	Next
	
	ret\hit = nearest_dist<1000
	
	Return ret
End Function


Function ray_sphere_intersect.ret_sphere(orig.vec3, dir.vec3, s.sphere); ret value is a pair [intersection found, distance]
	ret.ret_sphere = New ret_sphere
	ret\hit = False
	ret\dist = 0
	
	L.vec3 = vec3_sub(s\center, orig)
	tca# = vec3_dot(L,dir)
	d2# = vec3_dot(L,L) - tca*tca
	Delete L; cleanup
	If d2 > s\radius*s\radius Return ret
	thc# = Sqr(s\radius*s\radius - d2)
	t0# = tca-thc
	t1# = tca+thc
	If t0>.001 Then; offset the original point by .001 to avoid occlusion by the object itself
		ret\hit = True
		ret\dist = t0
		Return ret
	End If
	If t1>.001 Then
		ret\hit = True
		ret\dist = t1
		Return ret
	End If
	Return ret
End Function


Function reflect.vec3(I.vec3, N.vec3)
	v0.vec3 = vec3_scale(N, 2.0 * vec3_dot(I,N))
	ret.vec3 = vec3_sub(I, v0)
	Delete v0; cleanup
	Return ret
End Function


Function refract.vec3(I.vec3, N.vec3, eta_t#, eta_i# = 1.0); Snell's law
	cosi# = -Max(-1.0, Min(1.0, vec3_dot(I,N)))
	If cosi<0 Then; if the ray comes from the inside the object, swap the air and the media
		v0.vec3 = vec3_inv(N)
		ret.vec3 = refract(I, v0, eta_i, eta_t)
		Delete v0; cleanup
		Return ret
	End If
	eta# = eta_i / eta_t
	k# = 1 - eta*eta*(1 - cosi*cosi)
	If k<0 Then
		Return vec3(1,0,0)
	Else
		v0.vec3 = vec3_scale(I, eta)
		v1.vec3 = vec3_scale(N, (eta*cosi - Sqr(k)))
		ret.vec3 = vec3_add(v0, v1)
		Delete v0; cleanup
		Delete v1; cleanup
		Return ret; k<0 = total reflection, no ray to refract. I refract it anyways, this has no physical meaning
	End If
End Function


Function Min#(a#,b#)
	If a < b Then Return a Else Return b
End Function


Function Max#(a#,b#)
	If a > b Then Return a Else Return b
End Function


Function inkey()
	If KeyDown(1) Then; esc
		If fs Graphics width, height, 32, 2
		bail = True
	EndIf
	If KeyDown(56) Or KeyDown(184) Then; AltL / AltR
		If KeyDown(62) Then; f4
			If fs Graphics width, height, 32, 2
			bail = True
		EndIf
		If (KeyDown(28) Or KeyDown(156)) And kbready Then; Enter
			fs = Not fs
			If fs Then 
				Graphics 800, 600, 32, 1 
			Else
				Graphics width, height, 32, 2
			EndIf
			kbready = False
			img = CreateImage(width,height)
			If stage > 2 stage = 2
		End If
	ElseIf (Not KeyDown(28)) And (Not KeyDown(156)) Then
		kbready = True
	EndIf
End Function