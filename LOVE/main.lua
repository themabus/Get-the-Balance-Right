--320x240	 4040,  3885,  3777,  3851,  3695	<-- LuaJIT

require "vec3"

function love.load()
    width = 320
    height = 240
    fov = 1.05 -- 60 degrees field of view in radians

    jit.on()
    print(_VERSION)
    print(jit.version)
    print("Go!")
    time_start = os.clock() * 1000

    out_size = width*height
    time_step = 1000.0 / 60

    framebuffer = {}
    out = {}

    lights = {}
    spheres = {}

    -- materials --->
    mat = {
        refractive_index = 1.0,
        albedo = {2, 0, 0, 0},
        diffuse_color = vec3.new(),
        specular_exponent = 0
    }
    mat_white = {
        refractive_index = 1.0,
        albedo = {2, 0, 0, 0},
        diffuse_color = vec3.new(.3, .3, .3),
        specular_exponent = 0
    }
    mat_orange = {
        refractive_index = 1.0,
        albedo = {2, 0, 0, 0},
        diffuse_color = vec3.new(.3, .2, .1),
        specular_exponent = 0
    }
    ivory = {
        refractive_index = 1.0,
        albedo = {0.9, 0.5, 0.1, 0.0},
        diffuse_color = vec3.new(0.4, 0.4, 0.3),
        specular_exponent = 50.0
    }
    glass = {
        refractive_index = 1.5,
        albedo = {0.0, 0.9, 0.1, 0.8},
        diffuse_color = vec3.new(0.6, 0.7, 0.8),
        specular_exponent = 125.0
    }
    red_rubber = {
        refractive_index = 1.0,
        albedo = {1.4, 0.3, 0.0, 0.0},
        diffuse_color = vec3.new(0.3, 0.1, 0.1),
        specular_exponent = 10
    }
    mirror = {
        refractive_index = 1.0,
        albedo = {0.0, 16.0, 0.8, 0.0},
        diffuse_color = vec3.new(1.0, 1.0, 1.0),
        specular_exponent = 1425.0
    }
    -- <--- materials

    -- spheres --->
    spheres[1] = {
        center =  vec3.new(-3, 0, -16),
        radius = 2.0,
        material = ivory
    }
    spheres[2] = {
        center =  vec3.new(-1.0, -1.5, -12),
        radius = 2.0,
        material = glass
    }
    spheres[3] = {
        center =  vec3.new(1.5, -0.5, -18),
        radius = 3.0,
        material = red_rubber
    }
    spheres[4] = {
        center =  vec3.new(7, 5, -18),
        radius = 4.0,
        material = mirror
    }
    -- <--- spheres

    -- lights --->
    lights[1] = vec3.new(-20,20,20)
    lights[2] = vec3.new(30,50,-25)
    lights[3] = vec3.new(30,20,30)
    -- <--- lights

    stage = 0
    pix = 0

    love.window.setTitle("RayTracer256")
    love.window.setMode(width, height, {vsync=1})
    love.graphics.setDefaultFilter("nearest")
    canvas = love.graphics.newCanvas(width, height)
    scale_w = love.graphics.getWidth()
    scale_h = love.graphics.getHeight()

    label1 = "your score is and always has been"
end

function love.update(dt)
    local t = os.clock() * 1000
    
    if stage == 0 then
        local dir_z = -height/(2.0*math.tan(fov/2.0)) -- const
        while pix < out_size do
            local dir_x = (pix%width + 0.5) - width/2.0
            local dir_y = -(pix/width + 0.5) + height/2.0
            framebuffer[pix+1] = cast_ray(vec3.new(0,0,0), vec3.new(dir_x,dir_y,dir_z):normalized())
            pix = pix + 1
            if (os.clock() * 1000) - t > time_step then
                return
            end
        end
        pix = 0
        stage = stage + 1
    elseif stage == 1 then -- unneccesary loops left in deliberately
        while pix < out_size do
            local color = framebuffer[pix+1]
            local mx = math.max(1.0, math.max(color.x, math.max(color.y, color.z)))
            out[pix+1] = vec3.new(color.x/mx, color.y/mx, color.z/mx)
            pix = pix + 1
            if (os.clock() * 1000) - t > time_step then
                return
            end
        end
        stage = stage + 1
        time_end = (os.clock() * 1000) - time_start
        print(time_end)
    end
end

function love.draw()
    if stage == 0 then
        love.graphics.print(pix .. "/" .. out_size, 0,10*(scale_h/height), 0, scale_w/width,scale_h/height)
    elseif stage == 1 then
        love.graphics.print(out_size .. "/" .. out_size, 0,10*(scale_h/height), 0, scale_w/width,scale_h/height)
    elseif stage == 2 then
        love.graphics.setCanvas(canvas)
        pix = 0
        for i = 0, height-1 do
            for j = 0, width-1 do
                love.graphics.setColor(out[pix+1].x, out[pix+1].y, out[pix+1].z)
                love.graphics.points(j,i)
                pix = pix + 1
            end
        end
        love.graphics.setCanvas()
        love.graphics.setColor(1,1,1,1)
        stage = stage + 1
    end
    if stage == 3 then
        love.graphics.draw(canvas,0,0,0,scale_w/width,scale_h/height)
        love.graphics.print(label1, 0,0, 0, scale_w/width,scale_h/height)
        love.graphics.print(time_end, 0,10*(scale_h/height), 0, scale_w/width,scale_h/height)
    end
end

function cast_ray(orig, dir, depth)
    depth = depth or 0

    local hit, point, N, material = scene_intersect(orig, dir)

    if depth>4 or not hit then 
        return vec3.new(0.2, 0.7, 0.8) -- background color
    end

    local reflect_dir = reflect(dir, N):normalized()
    local refract_dir = refract(dir, N, material.refractive_index):normalized()
    local reflect_color = cast_ray(point, reflect_dir, depth + 1)
    local refract_color = cast_ray(point, refract_dir, depth + 1)

    local diffuse_light_intensity = 0
    local specular_light_intensity = 0
    
    for _, light in ipairs(lights) do -- checking if the point lies in the shadow of the light
        local light_dir = (light - point):normalized()
        local shadow_pt
        hit, shadow_pt = scene_intersect(point, light_dir)
        if hit and (shadow_pt-point):norm() < (light-point):norm() then goto continue end
        diffuse_light_intensity = diffuse_light_intensity + math.max(0., light_dir * N)
        specular_light_intensity = specular_light_intensity + math.pow(math.max(0., -reflect(-light_dir, N) * dir), material.specular_exponent)
        ::continue::
    end

    return material.diffuse_color * diffuse_light_intensity * material.albedo[1] + vec3.new(1., 1., 1.)*specular_light_intensity * material.albedo[2] + reflect_color*material.albedo[3] + refract_color*material.albedo[4]
end

function scene_intersect(orig, dir)
    local pt = vec3.new()
    local N = vec3.new()
    local material = mat

    local nearest_dist = 1e10
    if math.abs(dir.y)>.001 then -- intersect the ray with the checkerboard, avoid division by zero
        local d = -(orig.y+4)/dir.y -- the checkerboard plane has equation y = -4
        local p = orig + dir*d
        if d>.001 and d<nearest_dist and math.abs(p.x)<10 and p.z<-10 and p.z>-30 then
            nearest_dist = d
            pt = p
            N = vec3.new(0,1,0)
            material = bit.band(math.floor(.5*pt.x+1000) + math.floor(.5*pt.z), 1) == 0 and mat_white or mat_orange
        end
    end

    for _, s in ipairs(spheres) do -- intersect the ray with all spheres
        local intersection, d = ray_sphere_intersect(orig, dir, s)
        if (not intersection or d > nearest_dist) then goto continue end
        nearest_dist = d
        pt = orig + dir * nearest_dist
        N = (pt - s.center):normalized()
        material = s.material
        ::continue::
    end

    return nearest_dist<1000, pt, N, material
end

function ray_sphere_intersect(orig, dir, s) -- ret value is a pair [intersection found, distance]
    local L = s.center - orig
    local tca = L * dir
    local d2 = L*L - tca*tca
    if d2 > s.radius*s.radius then return false, 0 end
    local thc = math.sqrt(s.radius*s.radius - d2)
    local t0 = tca-thc
    local t1 = tca+thc
    if t0>.001 then return true, t0 end
    if t1>.001 then return true, t1 end

    return false, 0
end

function reflect(I, N)
    return I - N * 2.0 * (I*N)
end

function refract(I, N, eta_t, eta_i) -- Snell's law
    eta_i = eta_i or 1.0
    local cosi = -math.max(-1.0, math.min(1.0, I*N))
    if cosi<0 then return refract(I, -N, eta_i, eta_t) end -- if the ray comes from the inside the object, swap the air and the media
    local eta = eta_i / eta_t
    local k = 1 - eta*eta*(1 - cosi*cosi)

    return k<0 and vec3.new(1,0,0) or I*eta + N*(eta*cosi - math.sqrt(k)) -- k<0 = total reflection, no ray to refract. I refract it anyways, this has no physical meaning
end

function love.keypressed(key, scancode, isrepeat)
    if key == 'return' then
        if love.keyboard.isDown('lalt', 'ralt') then 
            love.window.setFullscreen(not love.window.getFullscreen(), "desktop")
            scale_w = love.graphics.getWidth()
            scale_h = love.graphics.getHeight()
        end
    elseif key == 'lalt' or key == 'ralt' then
        if love.keyboard.isDown('return') then 
            love.window.setFullscreen(not love.window.getFullscreen(), "desktop")
            scale_w = love.graphics.getWidth()
            scale_h = love.graphics.getHeight()
        end
    end
end
