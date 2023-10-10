#320x240	 7637,  7647,  7924,  7638,  7633	<- dev ide with debug stuff
#320x240	 5783,  5749,  5685,  5749,  5714	<- exported to exe

extends Node2D

var width = ProjectSettings.get_setting("display/window/size/width")
var height = ProjectSettings.get_setting("display/window/size/height")
var fov = 1.05	# 60 degrees field of view in radians

var out_size = width*height
var time_step = 1000.0 / 60

var framebuffer = [Vector3()]
var out = []

class Mat:
	var refractive_index: float = 1
	var albedo = [2,0,0,0]
	var diffuse_color = Vector3(0,0,0)
	var specular_exponent: float = 0
	
class Sphere:
	var center: Vector3
	var radius: float
	var material: Mat
	
var lights = [Vector3(-20, 20, 20), Vector3(30, 50, -25), Vector3(30, 20, 30)]
var spheres = []

var mat = Mat.new()
var mat_white = Mat.new()
var mat_orange = Mat.new()

var stage: int = 0
var pix: int = 0
var time_start
var time_end

var label1 = Label.new()
var label2 = Label.new()

	
func _ready():
	print("Go!")
	time_start = OS.get_ticks_msec()

	var ivory = Mat.new()
	ivory.refractive_index = 1.0
	ivory.albedo = [0.9, 0.5, 0.1, 0.0]
	ivory.diffuse_color = Vector3(0.4, 0.4, 0.3)
	ivory.specular_exponent = 50.0
	
	var glass = Mat.new()
	glass.refractive_index = 1.5
	glass.albedo = [0.0, 0.9, 0.1, 0.8]
	glass.diffuse_color = Vector3(0.6, 0.7, 0.8)
	glass.specular_exponent = 125.0
	
	var red_rubber = Mat.new()
	red_rubber.refractive_index = 1.0
	red_rubber.albedo = [1.4, 0.3, 0.0, 0.0]
	red_rubber.diffuse_color = Vector3(0.3, 0.1, 0.1)
	red_rubber.specular_exponent = 10.0
	
	var mirror = Mat.new()
	mirror.refractive_index = 1.0
	mirror.albedo = [0.0, 16.0, 0.8, 0.0]
	mirror.diffuse_color = Vector3(1.0, 1.0, 1.0)
	mirror.specular_exponent = 1425.0
	
	spheres = [Sphere.new(), Sphere.new(), Sphere.new(), Sphere.new()]
	spheres[0].center = Vector3(-3, 0, -16)
	spheres[0].radius = 2
	spheres[0].material = ivory
	spheres[1].center = Vector3(-1.0, -1.5, -12)
	spheres[1].radius = 2
	spheres[1].material = glass
	spheres[2].center = Vector3(1.5, -0.5, -18)
	spheres[2].radius = 3
	spheres[2].material = red_rubber
	spheres[3].center = Vector3(7, 5, -18)
	spheres[3].radius = 4
	spheres[3].material = mirror
	
	framebuffer.resize(out_size)
	out.resize(out_size)
	
	mat_white.diffuse_color = Vector3(.3, .3, .3)
	mat_orange.diffuse_color = Vector3(.3, .2, .1)
	
	label1.text = "your score is and always has been"
	label1.visible = false
	label2.rect_position = Vector2(0,12)
	add_child(label1)
	add_child(label2)
	

func _process(delta):
	var t = OS.get_ticks_msec()
	
	match stage:
		0:
			var dir_z: float = -height/(2.0*tan(fov/2.0)) # const
			while pix < out_size:
				var dir_x: float = (pix%width + 0.5) -  width/2.0
				var dir_y: float = -(pix/width + 0.5) + height/2.0
				framebuffer[pix] = cast_ray(Vector3(0,0,0), Vector3(dir_x,dir_y,dir_z).normalized())
				pix+=1
				if OS.get_ticks_msec() - t > time_step:
					label2.text = str(pix)+"/"+str(out_size)
					update()
					return
			label2.text = str(pix)+"/"+str(out_size)
			update()
			pix = 0
			stage+=1
		1: # unneccesary loops left in deliberately
			while pix < out_size:
				var color = framebuffer[pix]
				var mx: float = max(1.0, max(color.x, max(color.y, color.z)))
				out[pix] = Color(color.x/mx, color.y/mx, color.z/mx)
				pix+=1
				if OS.get_ticks_msec() - t > time_step:
					return
			update()
			stage+=1
			time_end = OS.get_ticks_msec() - time_start
			print(time_end)
			label2.text = str(time_end)
			label1.visible = true


func _draw():
	match stage:
		2:
			pix = 0
			for i in range(height):
				for j in range(width):
					draw_line(Vector2(j,i), Vector2(j+1,i), out[pix])
					pix += 1
		_:
			pass


func cast_ray(orig: Vector3, dir: Vector3, depth: int = 0):
	var tmp 
	tmp = scene_intersect(orig, dir)
	var hit = tmp[0]
	var point = tmp[1]
	var N = tmp[2]
	var material = tmp[3]
	
	if depth>4 || !hit:
		return Vector3(0.2, 0.7, 0.8)	# background color
		
	var reflect_dir = reflect(dir, N).normalized()
	var refract_dir = refract(dir, N, material.refractive_index).normalized()
	var reflect_color = cast_ray(point, reflect_dir, depth + 1)
	var refract_color = cast_ray(point, refract_dir, depth + 1)
	
	var diffuse_light_intensity: float = 0
	var specular_light_intensity: float = 0
	for light in lights:	# checking if the point lies in the shadow of the light
		var light_dir: Vector3 = (light - point).normalized()
		tmp = scene_intersect(point, light_dir)
		hit = tmp[0]
		var shadow_pt = tmp[1]
		if (hit && (shadow_pt-point).length() < (light-point).length()): continue
		diffuse_light_intensity += max(0.0, light_dir.dot(N))
		specular_light_intensity += pow(max(0.0, -reflect(-light_dir, N).dot(dir)),material.specular_exponent)
		
	return material.diffuse_color * diffuse_light_intensity * material.albedo[0] + Vector3(1.0, 1.0, 1.0)*specular_light_intensity * material.albedo[1] + reflect_color*material.albedo[2] + refract_color*material.albedo[3]

	
func scene_intersect(orig: Vector3, dir: Vector3):
	var pt: Vector3
	var N: Vector3
	var material = mat
	
	var nearest_dist: float = 1e10
	if abs(dir.y)>.001:	# intersect the ray with the checkerboard, avoid division by zero
		var d: float = -(orig.y+4)/dir.y	# the checkerboard plane has equation y = -4
		var p: Vector3 = orig + dir*d
		if (d>.001 && d<nearest_dist && abs(p.x)<10 && p.z<-10 && p.z>-30):
			nearest_dist = d
			pt = p
			N = Vector3(0,1,0)
			material = mat_white if ( int(.5*pt.x+1000) + int(.5*pt.z) ) & 1 else mat_orange
	
	var tmp
	for s in spheres:	# intersect the ray with all spheres
		tmp = ray_sphere_intersect(orig, dir, s)
		var intersection = tmp[0]
		var d = tmp[1]
		if (!intersection || d > nearest_dist): continue
		nearest_dist = d
		pt = orig + dir*nearest_dist
		N = (pt - s.center).normalized()
		material = s.material
	
	return [nearest_dist<1000, pt, N, material]


func ray_sphere_intersect(orig: Vector3, dir: Vector3, s: Sphere):	# ret value is a pair [intersection found, distance]
	var L: Vector3 = s.center - orig
	var tca: float = L.dot(dir)
	var d2: float = L.dot(L) - tca*tca
	if (d2 > s.radius*s.radius): return [false, 0]
	var thc: float = sqrt(s.radius*s.radius - d2)
	var t0: float = tca-thc
	var t1: float = tca+thc
	if (t0>.001): return [true, t0]
	if (t1>.001): return [true, t1]
	
	return [false, 0]

	
func reflect(I: Vector3, N: Vector3):
	return I - N*2.0 * I.dot(N)

	
func refract(I: Vector3, N: Vector3, eta_t: float, eta_i: float = 1.0):	# Snell's law
	var cosi: float = -max(-1.0, min(1.0, I.dot(N)))
	if (cosi<0): return refract(I, -N, eta_i, eta_t)	# if the ray comes from the inside the object, swap the air and the media
	var eta: float = eta_i / eta_t
	var k: float = 1 - eta*eta*(1 - cosi*cosi)
	
	return Vector3(1,0,0) if k<0 else I*eta + N*(eta*cosi - sqrt(k))	# k<0 = total reflection, no ray to refract. I refract it anyways, this has no physical meaning


func _input(event):
	if event is InputEventKey and event.pressed and !event.is_echo():
		if Input.is_key_pressed(KEY_ALT) and Input.is_key_pressed(KEY_ENTER):
			OS.window_fullscreen = !OS.window_fullscreen
