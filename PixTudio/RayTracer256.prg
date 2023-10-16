//320x240	16270, 15792, 16006, 15809, 16167

import "mod_say";
import "mod_text";
import "mod_video";
import "mod_key";
import "mod_wm";
import "mod_time";
import "mod_mem";
import "mod_map";
import "mod_draw";
import "mod_screen";

include "vec3.prg"

const
    R2D = 57295.7795130823;//180/pi

    width = 320;
    height = 240;
    fov = 1.05;// 60 degrees field of view in radians

    out_size = width*height;
    time_step = 1000.0 / 60;
end

type Material
    float refractive_index = 1;
    float albedo[] = 2,0,0,0;
    vec3 diffuse_color = 0,0,0;
    float specular_exponent = 0;
end

type Sphere
    vec3 center;
    float radius;
    Material material;
end

type ret_scene
    int hit;
    vec3 point;
    vec3 N;
    Material material;
end

type ret_sphere
    int hit;
    float dist;
end


global
    int time_start, time_end;

    vec3 framebuffer[out_size];
    int out[out_size];

    // materials --->
    Material        mat;
    Material  mat_white;
    Material mat_orange;
    Material      ivory = 1.0,   0.9, 0.5, 0.1, 0.0,    0.4, 0.4, 0.3,   50.0;
    Material      glass = 1.5,   0.0, 0.9, 0.1, 0.8,    0.6, 0.7, 0.8,  125.0;
    Material red_rubber = 1.0,   1.4, 0.3, 0.0, 0.0,    0.3, 0.1, 0.1,   10.0;
    Material     mirror = 1.0,   0.0,16.0, 0.8, 0.0,    1.0, 1.0, 1.0, 1425.0;
    // <--- materials

    Sphere spheres[4];
    vec3 lights[] = -20,20,20,  30,50,-25,  30,20,30;

    fs = false;
    bail = false;
    kbd_ready = true;
    int map;

    int stage = 0;
    int pix = 0;
end


process main()
begin
    say("Go!");
    time_start = get_timer();

    // spheres --->
    spheres[0].center.x = -3;
    spheres[0].center.y = 0;
    spheres[0].center.z = -16;
    spheres[0].radius = 2;
    spheres[0].material = ivory;

    spheres[1].center.x = -1.0;
    spheres[1].center.y = -1.5;
    spheres[1].center.z = -12;
    spheres[1].radius = 2;
    spheres[1].material = glass;

    spheres[2].center.x = 1.5;
    spheres[2].center.y = -0.5;
    spheres[2].center.z = -18;
    spheres[2].radius = 3;
    spheres[2].material = red_rubber;

    spheres[3].center.x = 7;
    spheres[3].center.y = 5;
    spheres[3].center.z = -18;
    spheres[3].radius = 4;
    spheres[3].material = mirror;
    // <--- spheres

    mat_white.diffuse_color.x  = 0.3; mat_white.diffuse_color.y  = 0.3; mat_white.diffuse_color.z  = 0.3;
    mat_orange.diffuse_color.x = 0.3; mat_orange.diffuse_color.y = 0.2; mat_orange.diffuse_color.z = 0.1;

    set_mode(width,height,32);
    set_fps(60,0);//0 = no frame skipping
    set_title("RayTracer256");
    map = map_new(width,height,32);
    scale_quality = 0;

    repeat
        input();
        update();
        frame;
    until(bail)
end


function update()
private
    int t;
    float dir_x, dir_y, dir_z;
    vec3 vec, zero;
    vec3 normalized;
    vec3 v_tmp;
    float mx;
    int color, i,j;
    string label1 = "your score is and always has been";
end
begin
    t = get_timer();

    switch (stage)
        case 0:
            dir_z = -height/(2.0*tan(R2D * fov/2.0));//const
            while (pix<out_size)
                dir_x = (pix%width + 0.5) - width/2.0;
                dir_y = -(pix/width + 0.5) + height/2.0;
                vec.x = dir_x; vec.y = dir_y; vec.z = dir_z;
                vec3_normalized(vec, &normalized);
                cast_ray(zero, normalized, 0, &framebuffer[pix]);
                pix++;
                if (get_timer() - t > time_step)
                    delete_text(0);
                    write(0, 0,20, ALIGN_TOP_LEFT, pix+"/"+out_size);
                    return;
                end
            end
            pix = 0;
            stage++;
        end
        case 1://unneccesary loops left in deliberately
            while (pix<out_size)
                v_tmp = framebuffer[pix];
                mx = v_tmp.y > v_tmp.z ? v_tmp.y : v_tmp.z;
                mx = v_tmp.x > mx ? v_tmp.x : mx;
                mx = 1.0 > mx ? 1.0 : mx;
                color = rgb(255*v_tmp.x/mx, 255*v_tmp.y/mx, 255*v_tmp.z/mx);
                out[pix] = color;
                pix++;
                if (get_timer() - t > time_step)
                    delete_text(0);
                    write(0, 0,20, ALIGN_TOP_LEFT, out_size+"/"+out_size);
                    return; 
                end;
            end
            pix = 0;
            stage++;
            time_end = get_timer() - time_start;
            say(time_end);
        end
        case 2:
            for (i=0; i<height; i++)
                for (j=0; j<width; j++)
                    map_put_pixel(0, map, j,i, out[pix]);
                    pix++;
                end
            end
            stage++;
            delete_text(0);
            write(0, 0,0, ALIGN_TOP_LEFT, label1);
            write(0, 0,20, ALIGN_TOP_LEFT, time_end);
        end
        default:
            screen_put(0,map);
        end
    end
end


function cast_ray(vec3 orig, vec3 dir, int depth, vec3 pointer ret)
private
    ret_scene scene, shadow;
    vec3 reflect_dir, refract_dir, reflect_color, refract_color;
    float diffuse_light_intensity, specular_light_intensity;
    int i;
    vec3 light_dir;
    float tmp, f1, f2;
    vec3 v1, v2, v3, v4, v5, v6;
end
begin
    scene_intersect(orig, dir, &scene);
    if (depth>4 || !scene.hit)
        ret.x = 0.2; ret.y = 0.7; ret.z = 0.8; // background color
        return;
    end

    reflect(dir, scene.N, &v1); vec3_normalized(v1, &reflect_dir);
    refract(dir, scene.N, scene.material.refractive_index, 1.0, &v1); vec3_normalized(v1, &refract_dir);
    cast_ray(scene.point, reflect_dir, depth + 1, &reflect_color);
    cast_ray(scene.point, refract_dir, depth + 1, &refract_color);

    for (i = 0; i < 3; i++) // checking if the point lies in the shadow of the light
        vec3_sub(lights[i], scene.point, &v1);
        vec3_normalized(v1, &light_dir);
        scene_intersect(scene.point, light_dir, &shadow);
        vec3_sub(shadow.point, scene.point, &v1);
        vec3_sub(lights[i], scene.point, &v2);
        if ( shadow.hit && vec3_norm(v1) < vec3_norm(v2) ) continue; end;
        tmp = vec3_dot(light_dir, scene.N);
        diffuse_light_intensity += tmp > 0 ? tmp : 0;
        vec3_inv(light_dir, &v1); reflect(v1, scene.N, &v2); vec3_inv(v2, &v3);
        tmp = vec3_dot(v3, dir);
        tmp = tmp > 0 ? tmp : 0;
        specular_light_intensity += pow(tmp, scene.material.specular_exponent);
    end

    f1 = diffuse_light_intensity * scene.material.albedo[0];
    f2 = specular_light_intensity * scene.material.albedo[1];
    vec3_scale(scene.material.diffuse_color, f1, &v1);
    v2.x = f2; v2.y = f2; v2.z = f2;
    vec3_scale(reflect_color, scene.material.albedo[2], &v3);
    vec3_scale(refract_color, scene.material.albedo[3], &v4);
    vec3_add(v1, v2, &v5); vec3_add(v5, v3, &v6); vec3_add(v6, v4, ret);
end


function scene_intersect(vec3 orig, vec3 dir, ret_scene pointer ret)
private
    float nearest_dist = 10000000000;//1e10
    float d;
    vec3 p, v1;
    int i;
    ret_sphere sphere;
end
begin
    memcopy(&ret.material,&mat,sizeof(Material));
    if (abs(dir.y)>0.001) // intersect the ray with the checkerboard, avoid division by zero
        d = -(orig.y+4)/dir.y; // the checkerboard plane has equation y = -4
        vec3_scale(dir, d, &v1); vec3_add(orig, v1, &p);
        if (d>0.001 && d<nearest_dist && abs(p.x)<10 && p.z<-10 && p.z>-30)
            nearest_dist = d;
            memcopy(&ret.point,&p,sizeof(vec3));
            ret.N.x = 0; ret.N.y = 1; ret.N.z = 0;
            ret.material.diffuse_color = ((int)(0.5*ret.point.x+1000) + (int)(0.5*ret.point.z)) & 1 ? mat_white.diffuse_color : mat_orange.diffuse_color;
        end
    end

    for (i = 0; i < 4; i++) // intersect the ray with all spheres
        ray_sphere_intersect(orig, dir, spheres[i], &sphere);
        if (!sphere.hit || sphere.dist > nearest_dist) continue; end;
        nearest_dist = sphere.dist;
        vec3_scale(dir, nearest_dist, &v1); vec3_add(orig, v1, &ret.point);
        vec3_sub(ret.point, spheres[i].center, &v1); vec3_normalized(v1, &ret.N);
        memcopy(ret.material,&spheres[i].material,sizeof(Material));
    end

    ret.hit = nearest_dist<1000;
end


function ray_sphere_intersect(vec3 orig, vec3 dir, Sphere s, ret_sphere pointer ret) // ret value is a pair [intersection found, distance]
private
    vec3 L;
    float tca, d2, thc, t0, t1;
end
begin
    vec3_sub(s.center, orig, &L);
    tca = vec3_dot(L, dir);
    d2 = vec3_dot(L, L) - tca*tca;
    if (d2 > s.radius*s.radius) 
        ret.hit = false;
        ret.dist = 0;
        return;
    end
    thc = sqrt(s.radius*s.radius - d2);
    t0 = tca-thc; t1 = tca+thc;
    if (t0>0.001)
        ret.hit = true;
        ret.dist = t0;
        return;
    end
    if (t1>0.001)
        ret.hit = true;
        ret.dist = t1;
        return;
    end
    ret.hit = false;
    ret.dist = 0;
end


function reflect(vec3 I, vec3 N, vec3 pointer ret)
private
    float tmp_f;
    vec3 tmp_v;
end
begin
    tmp_f = 2.0 * vec3_dot(I,N);
    vec3_scale(N, tmp_f, &tmp_v);
    vec3_sub(I, tmp_v, ret);
end


function refract(vec3 I, vec3 N, float eta_t, float eta_i, vec3 pointer ret) // Snell's law
private
    float cosi, eta, k;
    vec3 v1, v2;
end
begin
    cosi = vec3_dot(I, N); cosi = cosi < 1.0 ? cosi : 1.0; cosi = cosi > -1.0 ? cosi : -1.0; cosi = -cosi;
    if (cosi<0)
        vec3_inv(N, &v1);
        refract(I, v1, eta_i, eta_t, ret); // if the ray comes from the inside the object, swap the air and the media
        return;
    end
    eta = eta_i / eta_t;
    k = 1 - eta*eta*(1 - cosi*cosi);
    if (k<0) // k<0 = total reflection, no ray to refract. I refract it anyways, this has no physical meaning
        ret.x = 1; ret.y = 0; ret.z = 0;
        return;
    else
        vec3_scale(I, eta, &v1);
        vec3_scale(N, eta*cosi - sqrt(k), &v2);
        vec3_add(v1, v2, ret);
        return;
    end
end


process input()
begin
    if( key(_ESC) || ((key(_R_ALT) || key(_L_ALT)) && key(_F4)) )
        bail = true;
    elseif( (key(_R_ALT) || key(_L_ALT)) && key(_ENTER) )
        if (kbd_ready)
            fs = !fs;
            kbd_ready = false;
            full_screen = !full_screen;
            set_mode(width,height,32);
        end
    else
        kbd_ready = true;
    end
end