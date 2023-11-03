'320x240	  602,   596,   600,   594,   597
SuperStrict

Include "vec3.bmx"

Const width:Int = 320
Const height:Int = 240
Const fov:Float = 1.05' 60 degrees field of view in radians

Global time_start:Int = MilliSecs()
Print "Go!"

Global fps:Int = 60

Type Material
	Field refractive_index:Float = 1
	Field albedo:Float[] = [2.0, 0.0, 0.0, 0.0]
	Field diffuse_color:vec3
	Field specular_exponent:Int = 0
EndType

Type Sphere
	Field center:vec3
	Field radius:Float
	Field material:Material
EndType

Type ret_scene
	Field hit:Int
	Field point:vec3
	Field N:vec3
	Field material:Material
EndType

Type ret_sphere
	Field hit:Int
	Field dist:Float
EndType

Global out_size:Int = width * height
Global time_step:Float = 1000.0 / fps

Global framebuffer:vec3[out_size]
Global out:Int[out_size]

Global lights:vec3[3]
Global spheres:Sphere[4]

' materials --->
Global mat:Material = New Material
Global mat_white:Material = New Material
Global mat_orange:Material = New Material
mat.diffuse_color = vec3.Create()
mat_white.diffuse_color = vec3.Create(0.3, 0.3, 0.3)
mat_orange.diffuse_color = vec3.Create(0.3, 0.2, 0.1)

Local ivory:Material = New Material
ivory.refractive_index = 1.0
ivory.albedo[0] = 0.9
ivory.albedo[1] = 0.5
ivory.albedo[2] = 0.1
ivory.albedo[3] = 0.0
ivory.diffuse_color = vec3.Create(0.4, 0.4, 0.3)
ivory.specular_exponent = 50.0

Local glass:Material = New Material
glass.refractive_index = 1.5
glass.albedo[0] = 0.0
glass.albedo[1] = 0.9
glass.albedo[2] = 0.1
glass.albedo[3] = 0.8
glass.diffuse_color = vec3.Create(0.6, 0.7, 0.8)
glass.specular_exponent = 125.0

Local red_rubber:Material = New Material
red_rubber.refractive_index = 1.0
red_rubber.albedo[0] = 1.4
red_rubber.albedo[1] = 0.3
red_rubber.albedo[2] = 0.0
red_rubber.albedo[3] = 0.0
red_rubber.diffuse_color = vec3.Create(0.3, 0.1, 0.1)
red_rubber.specular_exponent = 10.0

Local mirror:Material = New Material
mirror.refractive_index = 1.0
mirror.albedo[0] = 0.0
mirror.albedo[1] = 16.0
mirror.albedo[2] = 0.8
mirror.albedo[3] = 0.0
mirror.diffuse_color = vec3.Create(1.0, 1.0, 1.0)
mirror.specular_exponent = 1425.0
' <--- materials

' spheres --->
spheres[0] = New Sphere
spheres[0].center = vec3.Create(-3, 0, -16)
spheres[0].radius = 2.0
spheres[0].material = ivory

spheres[1] = New Sphere
spheres[1].center = vec3.Create(-1.0, -1.5, -12)
spheres[1].radius = 2.0
spheres[1].material = glass

spheres[2] = New Sphere
spheres[2].center = vec3.Create(1.5, -0.5, -18)
spheres[2].radius = 3.0
spheres[2].material = red_rubber

spheres[3] = New Sphere
spheres[3].center = vec3.Create(7, 5, -18)
spheres[3].radius = 4.0
spheres[3].material = mirror
' <--- spheres

' lights --->
lights[0] = vec3.Create(-20,20,20)
lights[1] = vec3.Create(30,50,-25)
lights[2] = vec3.Create(30,20,30)
' <--- lights

Global stage:Int = 0
Global pix:Int = 0
Global D2R:Float = 180/Pi

AppTitle = "RayTracer256"
Graphics width,height,0,fps
Global zero:vec3 = vec3.Create()
Global bail:Int = False
Global fs:Int = False
Global kbready:Int = True
Global img:TImage = CreateImage(width,height, 1, 0)
Global time_end:Int = 0
Global label1:String = "your score is and always has been"


Repeat
	inkey()
	update()
	Flip
Until AppTerminate() Or bail


Function update()
	Local t:Int = MilliSecs()
	
	Select stage
		Case 0
			Local dir_z:Float = -height/(2.0*Tan(D2R*fov/2.0))' Const
			While pix < out_size' actual rendering loop
				Local dir_x:Float = (pix Mod width + 0.5) - width/2.0
				Local dir_y:Float = -(pix/width + 0.5) + height/2.0' this flips the image at the same time
				framebuffer[pix] = cast_ray(zero, vec3.Create(dir_x, dir_y, dir_z).normalized())
				pix = pix + 1
				If MilliSecs() - t > time_step Then
					Cls
					DrawText pix +"/" + out_size, 0,10
					Return
				EndIf
			Wend
			Cls
			DrawText pix +"/" + out_size, 0,10
			pix = 0
			stage = stage + 1
		Case 1' unneccesary loops left in deliberately
			While pix < out_size
				Local mx:Float = Max(1.0, Max(framebuffer[pix].x, Max(framebuffer[pix].y, framebuffer[pix].z)))
				out[pix] = 255 Shl 24 + Int(255*framebuffer[pix].x/mx) Shl 16 + Int(255*framebuffer[pix].y/mx) Shl 8 + Int(255*framebuffer[pix].z/mx)
				pix = pix + 1
				If MilliSecs() - t > time_step Then
					Cls
					DrawText out_size +"/" + out_size, 0,10
					Return
				EndIf
			Wend
			Cls
			DrawText out_size +"/" + out_size, 0,10
			pix = 0
			stage = stage + 1
			time_end = MilliSecs() - time_start
			Print time_end
		Case 2
			Local map:TPixmap = LockImage(img)
			For Local i:Int=0 To height-1
				For Local j:Int=0 To width-1
					WritePixel map, j, i, out[pix]
					pix = pix + 1
				Next
			Next
			UnlockImage(img)
			pix = 0
			stage = stage + 1
		Default
			DrawImage img,0,0
			DrawText label1, 0,0
			DrawText time_end, 0,10*GraphicsHeight()/Float(height)
	EndSelect
EndFunction


Function cast_ray:vec3(orig:vec3, dir:vec3, depth:Int = 0)
	Local scene:ret_scene = scene_intersect(orig, dir)
	
	If (depth>4) Or (scene.hit=0) Then
		Return vec3.Create(.2, .7, .8)' background color
	EndIf
	
	Local reflect_dir:vec3 = reflect(dir, scene.N).normalized()
	Local refract_dir:vec3 = refract(dir, scene.N, scene.material.refractive_index, 1.0).normalized()
	Local reflect_color:vec3 = cast_ray(scene.point, reflect_dir, depth + 1)
	Local refract_color:vec3 = cast_ray(scene.point, refract_dir, depth + 1)
	
	Local diffuse_light_intensity:Float = 0
	Local specular_light_intensity:Float = 0
	
	For Local i:Int=0 To Len(lights)-1' checking If the point lies in the shadow of the light
		Local light_dir:vec3 = lights[i].sub(scene.point).normalized()
		Local shadow:ret_scene = scene_intersect(scene.point, light_dir)
		If shadow.hit<>0 And shadow.point.sub(scene.point).norm() < lights[i].sub(scene.point).norm() Continue
		diffuse_light_intensity = diffuse_light_intensity + Max(0.0, light_dir.dot(scene.N))
		specular_light_intensity = specular_light_intensity + Max(0.0, reflect(light_dir.inv(), scene.N).inv().dot(dir)) ^ scene.material.specular_exponent
	Next
	
	Local f1:Float = diffuse_light_intensity * scene.material.albedo[0]
	Local f2:Float = specular_light_intensity * scene.material.albedo[1]
	Local v1:vec3 = scene.material.diffuse_color.scale(f1)
	Local v2:vec3 = vec3.Create(f2, f2, f2)
	Local v3:vec3 = reflect_color.scale(scene.material.albedo[2])
	Local v4:vec3 = refract_color.scale(scene.material.albedo[3])
	Return v1.add(v2).add(v3).add(v4)
EndFunction


Function scene_intersect:ret_scene(orig:vec3, dir:vec3)
	Local ret:ret_scene = New ret_scene
	ret.material = mat
	ret.point = vec3.Create()
	ret.N = vec3.Create()
	
	Local nearest_dist:Float = 1e10
	If Abs(dir.y)>.001 Then' intersect the ray with the checkerboard, avoid division by zero
		Local d:Float = -(orig.y+4)/dir.y' the checkerboard plane has equation y = -4
		Local p:vec3 = orig.add(dir.scale(d))
		If d>.001 And d<nearest_dist And Abs(p.x)<10 And p.z<-10 And p.z>-30 Then
			nearest_dist = d
			ret.point = p
			ret.N.y = 1
			If (Int(0.5*ret.point.x+1000) + Int(0.5*ret.point.z)) & 1 ret.material = mat_white Else ret.material = mat_orange
		EndIf
	EndIf
	
	For Local i:Int=0 To Len(spheres)-1' intersect the ray with all spheres
		Local sphere:ret_sphere = ray_sphere_intersect(orig, dir, spheres[i])
		If sphere.hit=False Or sphere.dist > nearest_dist Continue
		nearest_dist = sphere.dist
		ret.point = orig.add(dir.scale(nearest_dist))
		ret.N = ret.point.sub(spheres[i].center).normalized()
		ret.material = spheres[i].material
	Next
	
	ret.hit = nearest_dist<1000
	
	Return ret
EndFunction


Function ray_sphere_intersect:ret_sphere(orig:vec3, dir:vec3, s:sphere)' ret value is a pair [intersection found, distance]
	Local ret:ret_sphere = New ret_sphere
	ret.hit = False
	ret.dist = 0
	
	Local L:vec3 = s.center.sub(orig)
	Local tca:Float = L.dot(dir)
	Local d2:Float = L.dot(L) - tca*tca
	If d2 > s.radius*s.radius Return ret
	Local thc:Float = Sqr(s.radius*s.radius - d2)
	Local t0:Float = tca-thc
	Local t1:Float = tca+thc
	If t0>.001 Then' offset the original point by .001 To avoid occlusion by the Object itself
		ret.hit = True
		ret.dist = t0
		Return ret
	EndIf
	If t1>.001 Then
		ret.hit = True
		ret.dist = t1
		Return ret
	EndIf
	
	Return ret
EndFunction


Function reflect:vec3(I:vec3, N:vec3)
	Return I.sub(N.scale(2.0 * I.dot(N)))
EndFunction


Function refract:vec3(I:vec3, N:vec3, eta_t:Float, eta_i:Float = 1.0)' Snell's law
	Local cosi:Float = -Max(-1.0, Min(1.0, I.dot(N)))
	If cosi<0 Then' If the ray comes from the inside the Object, swap the air And the media
		Return refract(I, N.inv(), eta_i, eta_t)
	EndIf
	Local eta:Float = eta_i / eta_t
	Local k:Float = 1 - eta*eta*(1 - cosi*cosi)
	If k<0 Then
		Return vec3.Create(1,0,0)
	Else
		Return I.scale(eta).add(N.scale(eta*cosi - Sqr(k)))' k<0 = total reflection, no ray to refract. I refract it anyways, this has no physical meaning
	EndIf
EndFunction


Function inkey()
	If KeyDown(KEY_ESCAPE) Then
		If fs Graphics width, height, 0, fps
		bail = True
	EndIf
	If KeyDown(KEY_LALT) | KeyDown(KEY_RALT) Then
		If KeyDown(KEY_F4) Then
			If fs Graphics width, height, 0, fps
			bail = True
		EndIf
		If (KeyDown(KEY_RETURN) | KeyDown(KEY_ENTER)) & kbready Then
			fs = Not fs
			If fs Then
				Graphics 800, 600, 32, fps
			Else
				Graphics width, height, 0, fps
			EndIf
			kbready = False
			SetScale GraphicsWidth()/Float(width), GraphicsHeight()/Float(height)
		End If
	ElseIf (Not KeyDown(KEY_RETURN)) & (Not KeyDown(KEY_ENTER)) Then
		kbready = True
	EndIf
EndFunction
