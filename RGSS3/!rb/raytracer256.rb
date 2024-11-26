class RayTracer256
#============================================================================
  def initialize
  
    puts RUBY_VERSION
    puts "Go!"
    @time_start = (Time.now.to_f * 1000).to_i
    @time_end = 0
    @time_step = 1000.0 / Graphics.frame_rate
    @out_size = $width*$height

    @framebuffer = Array.new(@out_size)
    @out = Array.new(@out_size)

    @lights = Array[Vec3.new(-20, 20, 20), Vec3.new(30, 50, -25), Vec3.new(30, 20, 30)]
    @spheres = Array[Sphere.new(), Sphere.new(), Sphere.new(), Sphere.new()]

    # materials --->
    ivory = Material.new()
    ivory.refractive_index = 1.0
    ivory.albedo = Array[0.9, 0.5, 0.1, 0.0]
    ivory.diffuse_color = Vec3.new(0.4, 0.4, 0.3)
    ivory.specular_exponent = 50.0

    glass = Material.new()
    glass.refractive_index = 1.5
    glass.albedo = Array[0.0, 0.9, 0.1, 0.8]
    glass.diffuse_color = Vec3.new(0.6, 0.7, 0.8)
    glass.specular_exponent = 125.0

    red_rubber = Material.new()
    red_rubber.refractive_index = 1.0
    red_rubber.albedo = Array[1.4, 0.3, 0.0, 0.0]
    red_rubber.diffuse_color = Vec3.new(0.3, 0.1, 0.1)
    red_rubber.specular_exponent = 10.0
	
    mirror = Material.new()
    mirror.refractive_index = 1.0
    mirror.albedo = Array[0.0, 16.0, 0.8, 0.0]
    mirror.diffuse_color = Vec3.new(1.0, 1.0, 1.0)
    mirror.specular_exponent = 1425.0
    # <--- materials

    # spheres --->
    @spheres[0].center = Vec3.new(-3, 0, -16)
    @spheres[0].radius = 2.0
    @spheres[0].material = ivory
    @spheres[1].center = Vec3.new(-1.0, -1.5, -12)
    @spheres[1].radius = 2.0
    @spheres[1].material = glass
    @spheres[2].center = Vec3.new(1.5, -0.5, -18)
    @spheres[2].radius = 3.0
    @spheres[2].material = red_rubber
    @spheres[3].center = Vec3.new(7, 5, -18)
    @spheres[3].radius = 4.0
    @spheres[3].material = mirror
    # <--- spheres

    @stage = 0
    @pix = 0
    @clear = Color.new(0,0,0)
    
    @screen = Sprite.new()
    @screen.bitmap = Bitmap.new(544, 416)
    @sprite = Sprite.new()
    @sprite.bitmap = Bitmap.new($width, $height)

  end
  #--------------------------------------------------------------------------
  def update
    t = (Time.now.to_f * 1000).to_i
    
    case @stage
      when 0
        zero = Vec3.new(0, 0, 0)
        dir_z = -$height/(2.0*Math.tan($fov/2.0)) # const
        while @pix<@out_size do
          dir_x = (@pix%$width + 0.5) - $width/2.0
          dir_y = -(@pix/$width + 0.5) + $height/2.0
          @framebuffer[@pix] = cast_ray(zero, Vec3.new(dir_x,dir_y,dir_z).normalized)
          @pix+=1
          if (Time.now.to_f * 1000).to_i - t > @time_step
            @screen.bitmap.fill_rect(0,20, 120,20, @clear)  # RGSS2 .clear_rect
            @screen.bitmap.draw_text(0,20, 120,20, "#{@pix.to_s}/#{@out_size.to_s}")
            return
          end
        end
        @screen.bitmap.fill_rect(0,20, 120,20, @clear)
        @screen.bitmap.draw_text(0,20, 120,20, "#{@pix.to_s}/#{@out_size.to_s}")
        @pix = 0
        @stage+=1
      when 1
        while @pix<@out_size do
          color = @framebuffer[@pix]
          mx = [1.0, [color.x, [color.y, color.z].max].max].max
          @out[@pix] = Color.new(255*color.x/mx, 255*color.y/mx, 255*color.z/mx)
          @pix+=1
          if (Time.now.to_f * 1000).to_i - t > @time_step
            return
          end
        end
        @stage+=1
        @time_end = (Time.now.to_f * 1000).to_i - @time_start
        puts @time_end
      when 2
        # drawing --->
        k = 0
        for i in 0...$height do
          for j in 0...$width do
            @sprite.bitmap.set_pixel(j, i, @out[k])
            k+=1
          end
        end
        @screen.bitmap.stretch_blt(@screen.bitmap.rect, @sprite.bitmap, @sprite.bitmap.rect)
        @sprite.bitmap.clear()
        @screen.bitmap.draw_text(0, 0, 320, 20, "your score is and always has been")
        @screen.bitmap.draw_text(0, 20, 320, 20, @time_end.to_s)
        @stage+=1
        # <--- drawing
    end
  end
  #--------------------------------------------------------------------------
  #(Vec3, Vec3[, int])
  def cast_ray(orig, dir, depth = 0)
    hit, point, n, material = scene_intersect(orig, dir)
    
    if (depth>4 || !hit)
      return Vec3.new(0.2, 0.7, 0.8)  # background color
    end
      
    reflect_dir = reflect(dir, n).normalized()
    refract_dir = refract(dir, n, material.refractive_index).normalized()
    reflect_color = cast_ray(point, reflect_dir, depth + 1)
    refract_color = cast_ray(point, refract_dir, depth + 1)
    
    diffuse_light_intensity = 0.0
    specular_light_intensity = 0.0
    for light in @lights do
      light_dir = (light - point).normalized()
      hit, shadow_pt = scene_intersect(point, light_dir)
      if hit && (shadow_pt-point).norm() < (light-point).norm()
        next
      end
      diffuse_light_intensity += [0.0, light_dir*n].max()
      specular_light_intensity += [0.0, -reflect(-light_dir, n)*dir].max() ** material.specular_exponent
    end
    
    return material.diffuse_color * diffuse_light_intensity * material.albedo[0] + Vec3.new(1.0, 1.0, 1.0)*specular_light_intensity * material.albedo[1] + reflect_color*material.albedo[2] + refract_color*material.albedo[3]
  end
  #--------------------------------------------------------------------------
  #(Vec3, Vec3)
  def scene_intersect(orig, dir)
    pt = Vec3.new()
    n = Vec3.new()
    material = Material.new()
    
    nearest_dist = 10000000000.0
    if dir.y.abs()>0.001  # intersect the ray with the checkerboard, avoid division by zero
      d = -(orig.y+4)/dir.y # the checkerboard plane has equation y = -4
      p = orig + dir*d
      if d>0.001 && d<nearest_dist && p.x.abs()<10 && p.z<-10 && p.z>-30
        nearest_dist = d
        pt = p
        n = Vec3.new(0,1,0)
        material.diffuse_color = !(( (0.5*pt.x+1000).to_i + (0.5*pt.z).to_i ) & 1).zero? ? Vec3.new(0.3, 0.3, 0.3) : Vec3.new(0.3, 0.2, 0.1)
      end
    end
    
    for s in @spheres do  # intersect the ray with all spheres
      intersection, d = ray_sphere_intersect(orig, dir, s)
      if (!intersection || d > nearest_dist)
        next
      end
      nearest_dist = d
      pt = orig + dir*nearest_dist
      n = (pt - s.center).normalized()
      material = s.material
    end
    return nearest_dist<1000, pt, n, material
  end
  #--------------------------------------------------------------------------
  #(Vec3, Vec3, Sphere)
  def ray_sphere_intersect(orig, dir, s)  # ret value is a pair [intersection found, distance]
    l = s.center - orig # Vec3
    tca = l*dir         # float
    d2 = l*l - tca*tca  # float
    if d2 > s.radius*s.radius
      return [false, 0]
    end
    thc = Math.sqrt(s.radius*s.radius - d2) #float
    t0 = tca-thc  # float
    t1 = tca+thc  # float
    if t0>0.001   # offset the original point by .001 to avoid occlusion by the object itself
      return [true, t0]
    end
    if t1>0.001
      return [true, t1]
    end
    return [false, 0]
  end
  #--------------------------------------------------------------------------
  #(Vec3, Vec3)
  def reflect(i, n)
    return i - n*2.0*(i*n)
  end
  #--------------------------------------------------------------------------  
  #(Vec3, Vec3, float[, float])
  def refract(i, n, eta_t, eta_i=1.0) # Snell's law
    cosi = -[-1.0, [1.0, i*n].min].max  # float
    if cosi<0 # if the ray comes from the inside the object, swap the air and the media
      return refract(i, -n, eta_i, eta_t)
    end
    eta = eta_i / eta_t             # float
    k = 1 - eta*eta*(1 - cosi*cosi) # float
    return k<0 ? Vec3.new(1,0,0) : i*eta + n*(eta*cosi - Math.sqrt(k))  # k<0 = total reflection, no ray to refract. I refract it anyways, this has no physical meaning
  end
#============================================================================
end
