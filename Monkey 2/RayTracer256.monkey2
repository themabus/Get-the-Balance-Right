'320x240	  743,   736,   759,   745,   751

Namespace myapp

#Import "<std>"
#Import "<mojo>"

Using std..
Using mojo..

Class Material
	Field refractive_index:Float = 1
	Field albedo:Float[] = New Float[4](2.0, 0.0, 0.0, 0.0)
	Field diffuse_color:Vec3f
	Field specular_exponent:Int = 0
End

Class Sphere
	Field center:Vec3f
	Field radius:Float
	Field material:Material
End

Class ret_scene
	Field hit:Int
	Field point:Vec3f
	Field N:Vec3f
	Field material:Material
End

Class ret_sphere
	Field hit:Int
	Field dist:Float
End

Class MyWindow Extends Window
	Const width:Int = 320
	Const height:Int = 240
	Const fov:Float = 1.05' 60 degrees field of view in radians
	
	Field time_start:Int = Millisecs()
	Global fps:Int = 60

	Global out_size:Int = width * height
	Field time_step:Float = 1000.0 / fps

	Field framebuffer:Vec3f[] = New Vec3f[out_size]
	Field out:UInt[] = New UInt[out_size]

	Global lights:Vec3f[] = New Vec3f[3]
	Global spheres:Sphere[] = New Sphere[4]
	
	' materials --->
	Global mat:Material = New Material
	Global mat_white:Material = New Material
	Global mat_orange:Material = New Material
	Field ivory:Material = New Material
	Field glass:Material = New Material
	Field red_rubber:Material = New Material
	Field mirror:Material = New Material
	' <--- materials
	
	Field stage:Int = 0
	Field pix:Int = 0

	Global zero:Vec3f = New Vec3f()
	Global map:Pixmap = New Pixmap(width,height, PixelFormat.RGBA32)
	Global img:Image = New Image(width,height, TextureFlags.Dynamic)
	Global time_end:Int = 0
	Global label1:String = "your score is and always has been"
	Global sx:Float = 1
	Global sy:Float = 1
	Const vr:=New Vec2i(width,height)
	
	
	Method New( title:String="RayTracer256",width:Int=width,height:Int=height,flags:WindowFlags=Null )
		Super.New(title,width,height,flags)
		Layout="letterbox"
		
		' materials --->
		mat.diffuse_color = New Vec3f()
		mat_white.diffuse_color = New Vec3f(0.3, 0.3, 0.3)
		mat_orange.diffuse_color = New Vec3f(0.3, 0.2, 0.1)
		
		ivory.refractive_index = 1.0
		ivory.albedo[0] = 0.9
		ivory.albedo[1] = 0.5
		ivory.albedo[2] = 0.1
		ivory.albedo[3] = 0.0
		ivory.diffuse_color = New Vec3f(0.4, 0.4, 0.3)
		ivory.specular_exponent = 50.0
		
		glass.refractive_index = 1.5
		glass.albedo[0] = 0.0
		glass.albedo[1] = 0.9
		glass.albedo[2] = 0.1
		glass.albedo[3] = 0.8
		glass.diffuse_color = New Vec3f(0.6, 0.7, 0.8)
		glass.specular_exponent = 125.0
		
		red_rubber.refractive_index = 1.0
		red_rubber.albedo[0] = 1.4
		red_rubber.albedo[1] = 0.3
		red_rubber.albedo[2] = 0.0
		red_rubber.albedo[3] = 0.0
		red_rubber.diffuse_color = New Vec3f(0.3, 0.1, 0.1)
		red_rubber.specular_exponent = 10.0
		
		mirror.refractive_index = 1.0
		mirror.albedo[0] = 0.0
		mirror.albedo[1] = 16.0
		mirror.albedo[2] = 0.8
		mirror.albedo[3] = 0.0
		mirror.diffuse_color = New Vec3f(1.0, 1.0, 1.0)
		mirror.specular_exponent = 1425.0
		' <--- materials
		
		' spheres --->
		spheres[0] = New Sphere
		spheres[0].center = New Vec3f(-3, 0, -16)
		spheres[0].radius = 2.0
		spheres[0].material = ivory
		
		spheres[1] = New Sphere
		spheres[1].center = New Vec3f(-1.0, -1.5, -12)
		spheres[1].radius = 2.0
		spheres[1].material = glass
		
		spheres[2] = New Sphere
		spheres[2].center = New Vec3f(1.5, -0.5, -18)
		spheres[2].radius = 3.0
		spheres[2].material = red_rubber
		
		spheres[3] = New Sphere
		spheres[3].center = New Vec3f(7, 5, -18)
		spheres[3].radius = 4.0
		spheres[3].material = mirror
		' <--- spheres
		
		' lights --->
		lights[0] = New Vec3f(-20,20,20)
		lights[1] = New Vec3f(30,50,-25)
		lights[2] = New Vec3f(30,20,30)
		' <--- lights
	End

	
	Method OnMeasure:Vec2i() Override
		Return vr
	End


	Method OnRender( canvas:Canvas ) Override
		App.RequestRender()

		Local t:Int = Millisecs()
		
		Select stage
			Case 0
				Local dir_z:Float = -height/(2.0*Tan(fov/2.0))' Const
				While pix < out_size' actual rendering loop
					Local dir_x:Float = (pix Mod width + 0.5) - width/2.0
					Local dir_y:Float = -(pix/width + 0.5) + height/2.0' this flips the image at the same time
					framebuffer[pix] = cast_ray(zero, New Vec3f(dir_x, dir_y, dir_z).Normalize())
					pix+=1
					If Millisecs() - t > time_step Then
						canvas.DrawText(pix +"/"+ out_size, 0,15, 0,0)
						Return
					Endif
				Wend
				pix = 0
				stage+=1
				canvas.DrawText(out_size +"/"+ out_size, 0,15, 0,0)
			Case 1' unneccesary loops left in deliberately
				While pix < out_size
					Local mx:Float = Max(1.0, Max(framebuffer[pix].x, Max(framebuffer[pix].y, framebuffer[pix].z)))
					out[pix] = (255 Shl 24) + (UInt(255*framebuffer[pix].x/mx) Shl 16) + (UInt(255*framebuffer[pix].y/mx) Shl 8) + (UInt(255*framebuffer[pix].z/mx))
					pix+=1
					If Millisecs() - t > time_step Then
						canvas.DrawText(out_size +"/"+ out_size, 0,15, 0,0)
						Return
					Endif
				Wend
				pix = 0
				stage+=1
				time_end = Millisecs() - time_start
				Print time_end
				canvas.DrawText(out_size +"/"+ out_size, 0,15, 0,0)
			Case 2
				For Local i:Int=0 To height-1
					For Local j:Int=0 To width-1
						map.SetPixelARGB(j, i, out[pix])
						pix = pix + 1
					Next
				Next
				stage+=1
				img.Texture.PastePixmap(map,0,0)
			Default
				canvas.DrawRect(0,0, width*sx,height*sy, img)
				canvas.DrawText(label1, 0,0, 0,0)
				canvas.DrawText(time_end, 0,15, 0,0)
		End
	End
	
	
	Function cast_ray:Vec3f(orig:Vec3f, dir:Vec3f, depth:Int = 0)
		Local scene:ret_scene = scene_intersect(orig, dir)
		
		If (depth>4) Or (scene.hit=0) Then
			Return New Vec3f(.2, .7, .8)' background color
		Endif
		
		Local reflect_dir:Vec3f = reflect(dir, scene.N).Normalize()
		Local refract_dir:Vec3f = refract(dir, scene.N, scene.material.refractive_index, 1.0).Normalize()
		Local reflect_color:Vec3f = cast_ray(scene.point, reflect_dir, depth + 1)
		Local refract_color:Vec3f = cast_ray(scene.point, refract_dir, depth + 1)
		
		Local diffuse_light_intensity:Float = 0
		Local specular_light_intensity:Float = 0
		
		For Local i:Int=0 To lights.Length-1' checking If the point lies in the shadow of the light
			Local light_dir:Vec3f = (lights[i] - scene.point).Normalize()
			Local shadow:ret_scene = scene_intersect(scene.point, light_dir)
			If shadow.hit<>0 And (shadow.point - scene.point).Length < (lights[i] - scene.point).Length Continue
			diffuse_light_intensity += Max(0.0, light_dir.Dot(scene.N))
			specular_light_intensity += Pow(Max(0.0, (-reflect(-light_dir, scene.N)).Dot(dir)), scene.material.specular_exponent)
		Next
		
		Local f1:Float = diffuse_light_intensity * scene.material.albedo[0]
		Local f2:Float = specular_light_intensity * scene.material.albedo[1]
		Local v1:Vec3f = scene.material.diffuse_color * f1
		Local v2:Vec3f = New Vec3f(f2, f2, f2)
		Local v3:Vec3f = reflect_color * scene.material.albedo[2]
		Local v4:Vec3f = refract_color * scene.material.albedo[3]
		Return v1+v2+v3+v4
	End
	
	
	Function scene_intersect:ret_scene(orig:Vec3f, dir:Vec3f)
		Local ret:ret_scene = New ret_scene
		ret.material = mat
		ret.point = New Vec3f()
		ret.N = New Vec3f()
		
		Local nearest_dist:Float = 1e10
		If Abs(dir.y)>.001 Then' intersect the ray with the checkerboard, avoid division by zero
			Local d:Float = -(orig.y+4)/dir.y' the checkerboard plane has equation y = -4
			Local p:Vec3f = orig + dir * d
			If d>.001 And d<nearest_dist And Abs(p.x)<10 And p.z<-10 And p.z>-30 Then
				nearest_dist = d
				ret.point = p
				ret.N.y = 1
				If (Int(0.5*ret.point.x+1000) + Int(0.5*ret.point.z)) & 1 ret.material = mat_white Else ret.material = mat_orange
			Endif
		Endif
		For Local i:Int=0 To spheres.Length-1' intersect the ray with all spheres
			Local sphere:ret_sphere = ray_sphere_intersect(orig, dir, spheres[i])
			If sphere.hit=False Or sphere.dist > nearest_dist Continue
			nearest_dist = sphere.dist
			ret.point = orig + dir * nearest_dist
			ret.N = (ret.point - spheres[i].center).Normalize()
			ret.material = spheres[i].material
		Next
		ret.hit = nearest_dist<1000
		
		Return ret
	End


	Function ray_sphere_intersect:ret_sphere(orig:Vec3f, dir:Vec3f, s:Sphere)' ret value is a pair [intersection found, distance]
		Local ret:ret_sphere = New ret_sphere
		ret.hit = False
		ret.dist = 0
		
		Local L:Vec3f = s.center - orig
		Local tca:Float = L.Dot(dir)
		Local d2:Float = L.Dot(L) - tca*tca
		If d2 > s.radius*s.radius Return ret
		Local thc:Float = Sqrt(s.radius*s.radius - d2)
		Local t0:Float = tca-thc
		Local t1:Float = tca+thc
		If t0>.001 Then' offset the original point by .001 To avoid occlusion by the Object itself
			ret.hit = True
			ret.dist = t0
			Return ret
		Endif
		If t1>.001 Then
			ret.hit = True
			ret.dist = t1
			Return ret
		Endif
		
		Return ret
	End
	
	
	Function reflect:Vec3f(I:Vec3f, N:Vec3f)
		Return I - N * 2.0 * I.Dot(N) 
	End
	
	
	Function refract:Vec3f(I:Vec3f, N:Vec3f, eta_t:Float, eta_i:Float = 1.0)' Snell's law
		Local cosi:Float = -Max(-1.0, Min(1.0, I.Dot(N)))
		If cosi<0 Then' If the ray comes from the inside the Object, swap the air And the media
			Return refract(I, -N, eta_i, eta_t)
		Endif
		Local eta:Float = eta_i / eta_t
		Local k:Float = 1 - eta*eta*(1 - cosi*cosi)
		If k<0 Then
			Return New Vec3f(1,0,0)
		Else
			Return I*eta + N*(eta*cosi - Sqrt(k))' k<0 = total reflection, no ray to refract. I refract it anyways, this has no physical meaning
		Endif
	End

	
	Method OnKeyEvent(event:KeyEvent) Override
		select event.Type
			Case EventType.KeyDown
				If (event.Key=Key.Enter And event.Modifiers & Modifier.Alt)
					If Fullscreen EndFullscreen() Else BeginFullscreen()
					sx = Width/width
					sy = Height/height
				Endif
				If (event.Key=Key.Escape) App.Terminate()
		End
	End
End


Function Main()
	Print "Go!"
	New AppInstance
	New MyWindow
	App.Run()
End
