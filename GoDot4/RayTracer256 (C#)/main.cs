//320x240	  492,   503,   507,   494,   501	<- dev ide with debug stuff
//320x240	  216,   234,   231,   234,   242	<- exported to exe

using Godot;
using System;

public partial class main : Node2D {
	static int width = (int)ProjectSettings.GetSetting("display/window/size/viewport_width");
	static int height = (int)ProjectSettings.GetSetting("display/window/size/viewport_height");
	double fov = 1.05; // 60 degrees field of view in radians
	
	static int out_size = width * height;
	double time_step = 1000.0 / 60;
	
	Vector3[] framebuffer = new Vector3[out_size];
	Color[] output = new Color[out_size];
	
	public struct Material {
		public double refractive_index;
		public double[] albedo;
		public Vector3 diffuse_color;
		public double specular_exponent;
	}
	public struct Sphere {
		public Vector3 center;
		public double radius;
		public Material material;
	}
	
	Vector3[] lights = {new Vector3(-20,20,20), new Vector3(30,50,-25), new Vector3(30,20,30)};
	Sphere[] spheres = {new Sphere(), new Sphere(), new Sphere(), new Sphere()};
	
	Material mat;
	Material mat_white;
	Material mat_orange;
	
	int stage = 0;
	int pix = 0;
	ulong time_start;
	ulong time_end;
	
	Label label1 = new Label();
	Label label2 = new Label();

	public override void _Ready() {
		GD.Print("Go!");
		time_start = Time.GetTicksMsec();
		
		// materials --->
		mat.refractive_index = 1;
		mat.albedo = new double[4] {2, 0, 0, 0};
		mat.diffuse_color = new Vector3(0, 0, 0);
		mat.specular_exponent = 0;
		
		mat_white.refractive_index = 1;
		mat_white.albedo = new double[4] {2, 0, 0, 0};
		mat_white.diffuse_color = new Vector3(0.3f, 0.3f, 0.3f);
		mat_white.specular_exponent = 0;
		
		mat_orange.refractive_index = 1;
		mat_orange.albedo = new double[4] {2, 0, 0, 0};
		mat_orange.diffuse_color = new Vector3(0.3f, 0.2f, 0.1f);
		mat_orange.specular_exponent = 0;
		
		Material ivory;
		ivory.refractive_index = 1.0;
		ivory.albedo = new double[4] {0.9, 0.5, 0.1, 0.0};
		ivory.diffuse_color = new Vector3(0.4f, 0.4f, 0.3f);
		ivory.specular_exponent = 50.0;
		
		Material glass;
		glass.refractive_index = 1.5;
		glass.albedo = new double[4] {0.0, 0.9, 0.1, 0.8};
		glass.diffuse_color = new Vector3(0.6f, 0.7f, 0.8f);
		glass.specular_exponent = 125.0;
		
		Material red_rubber;
		red_rubber.refractive_index = 1.0;
		red_rubber.albedo = new double[4] {1.4, 0.3, 0.0, 0.0};
		red_rubber.diffuse_color = new Vector3(0.3f, 0.1f, 0.1f);
		red_rubber.specular_exponent = 10.0;
		
		Material mirror;
		mirror.refractive_index = 1.0;
		mirror.albedo = new double[4] {0.0, 16.0, 0.8, 0.0};
		mirror.diffuse_color = new Vector3(1.0f, 1.0f, 1.0f);
		mirror.specular_exponent = 1425.0;
		// <--- materials
		
		// spheres --->
		spheres[0].center = new Vector3(-3, 0, -16);
		spheres[0].radius = 2.0;
		spheres[0].material = ivory;
		spheres[1].center = new Vector3(-1.0f, -1.5f, -12f);
		spheres[1].radius = 2.0;
		spheres[1].material = glass;
		spheres[2].center = new Vector3(1.5f, -0.5f, -18f);
		spheres[2].radius = 3.0;
		spheres[2].material = red_rubber;
		spheres[3].center = new Vector3(7f, 5f, -18f);
		spheres[3].radius = 4.0;
		spheres[3].material = mirror;
		// <--- spheres
		
		// labels --->
		label1.Text = "your score is and always has been";
		label1.Visible = false;
		label2.Position = new Vector2(0,12);
		AddChild(label1);
		AddChild(label2);
		// <--- labels
	}
	
	
  	public override void _Process(double delta) {
		ulong t = Time.GetTicksMsec();
		
		switch(stage) {
			case 0:
				double dir_z = -height/(2.0*Math.Tan(fov/2.0)); //const
				while (pix < out_size) {
					double dir_x = (pix%width + 0.5) - width/2.0;
					double dir_y = -(pix/width + 0.5) + height/2.0;
					framebuffer[pix] = cast_ray(new Vector3(0,0,0), new Vector3((float)dir_x,(float)dir_y,(float)dir_z).Normalized());
					pix++;
					if (Time.GetTicksMsec() - t > time_step) {
						label2.Text = $"{pix}/{out_size}";
						return;
					}
				}
				label2.Text = $"{pix}/{out_size}";
				pix = 0;
				stage++;
			break;
			
			case 1: // unneccesary loops left in deliberately
				while (pix < out_size) {
					Vector3 color = framebuffer[pix];
					float mx = Math.Max(1.0f, Math.Max(color.X, Math.Max(color.Y, color.Z)));
					output[pix] = new Color(color.X/mx, color.Y/mx, color.Z/mx);
					pix++;
					if (Time.GetTicksMsec() - t > time_step)
						return;
				}
				QueueRedraw();
				stage++;
				time_end = Time.GetTicksMsec() - time_start;
				GD.Print(time_end);
				label2.Text = $"{time_end}";
				label1.Visible = true;
			break;
		}
  	}
	
	
	public override void _Draw() {
		switch(stage) {
			case 2:
				int pix = 0;
				for (int i=0; i<height; i++) {
					for (int j=0; j<width; j++) {
						DrawLine(new Vector2(j,i), new Vector2(j+1,i), output[pix]);
						pix++;
					}
				}
			break;
		}
	}
	
	
	public Vector3 cast_ray(Vector3 orig, Vector3 dir, int depth = 0) {
		bool hit;
		Vector3 point;
		Vector3 N;
		Material material;
		(hit, point, N, material) = scene_intersect(orig, dir);
		
		if (depth>4 || !hit)
			return new Vector3(0.2f, 0.7f, 0.8f); // background color
		
		Vector3 reflect_dir = reflect(dir, N).Normalized();
		Vector3 refract_dir = refract(dir, N, material.refractive_index).Normalized();
		Vector3 reflect_color = cast_ray(point, reflect_dir, depth + 1);
		Vector3 refract_color = cast_ray(point, refract_dir, depth + 1);
		
		double diffuse_light_intensity = 0;
		double specular_light_intensity = 0;
		foreach (Vector3 light in lights) { // checking if the point lies in the shadow of the light
			Vector3 light_dir = (light - point).Normalized();
			Vector3 shadow_pt;
			Vector3 dummy1;
			Material dummy2;
			(hit, shadow_pt, dummy1, dummy2) = scene_intersect(point, light_dir);
			if (hit && (shadow_pt-point).Length() < (light-point).Length()) continue;
			diffuse_light_intensity += Math.Max(0.0, light_dir.Dot(N));
			specular_light_intensity += Math.Pow(Math.Max(0.0, -reflect(-light_dir, N).Dot(dir)),material.specular_exponent);
		}
		
		return material.diffuse_color * (float)(diffuse_light_intensity * material.albedo[0]) + new Vector3(1, 1, 1)*(float)(specular_light_intensity * material.albedo[1]) + reflect_color*(float)material.albedo[2] + refract_color*(float)material.albedo[3];
	}
	
	
	public (bool, Vector3, Vector3, Material) scene_intersect(Vector3 orig, Vector3 dir) {
		Vector3 pt = new Vector3(0,0,0);
		Vector3 N = new Vector3(0,0,0);
		Material material = mat;
		
		double nearest_dist = 1e10;
		if (Math.Abs(dir.Y)>.001) { // intersect the ray with the checkerboard, avoid division by zero
			float d = -(orig.Y+4)/dir.Y; // the checkerboard plane has equation y = -4
			Vector3 p = orig + dir*d;
			if (d>.001 && d<nearest_dist && Math.Abs(p.X)<10 && p.Z<-10 && p.Z>-30) {
				nearest_dist = d;
				pt = p;
				N = new Vector3(0,1,0);
				material = (( (int)(.5*pt.X+1000) + (int)(.5*pt.Z) ) & 1) == 1 ? mat_white : mat_orange;
			}
		}
		
		foreach (Sphere s in spheres) { // intersect the ray with all spheres
			bool intersection;
			double d;
			(intersection, d) = ray_sphere_intersect(orig, dir, s);
			if (!intersection || d > nearest_dist) continue;
			nearest_dist = d;
			pt = orig + dir*(float)nearest_dist;
			N = (pt - s.center).Normalized();
			material = s.material;
		}
		
		return (nearest_dist<1000, pt, N, material);
	}
	
	
	public (bool, double) ray_sphere_intersect(Vector3 orig, Vector3 dir, Sphere s) { // ret value is a pair [intersection found, distance]
		Vector3 L = s.center - orig;
		double tca = L.Dot(dir);
		double d2 = L.Dot(L) - tca*tca;
		if (d2 > s.radius*s.radius) return (false, 0);
		double thc = Math.Sqrt(s.radius*s.radius - d2);
		double t0 = tca-thc;
		double t1 = tca+thc;
		if (t0>.001) return (true, t0);
		if (t1>.001) return (true, t1);
		
		return (false, 0);
	}
	
	
	public Vector3 reflect(Vector3 I, Vector3 N) {
		return I - N*2.0f * I.Dot(N);
	}
	
	
	public Vector3 refract(Vector3 I, Vector3 N, double eta_t, double eta_i = 1) {	// Snell's law
		double cosi = -Math.Max(-1.0f, Math.Min(1.0f, I.Dot(N)));
		if (cosi<0) return refract(I, -N, eta_i, eta_t); // if the ray comes from the inside the object, swap the air and the media
		double eta = eta_i / eta_t;
		double k = 1 - eta*eta*(1 - cosi*cosi);
		
		return k<0 ? new Vector3(1,0,0) : I*(float)eta + N*(float)(eta*cosi - Math.Sqrt(k)); // k<0 = total reflection, no ray to refract. I refract it anyways, this has no physical meaning
	}
	
	
	public override void _Input(InputEvent @event) {
		if (@event is InputEventKey keyEvent && keyEvent.Pressed && !keyEvent.IsEcho()) {
			if(Input.IsKeyPressed(Key.Enter) && Input.IsKeyPressed(Key.Alt)) {
				GetWindow().Mode = !((GetWindow().Mode == Window.ModeEnum.ExclusiveFullscreen) || (GetWindow().Mode == Window.ModeEnum.Fullscreen)) ? Window.ModeEnum.ExclusiveFullscreen : Window.ModeEnum.Windowed;
			}
		}
	}
}
