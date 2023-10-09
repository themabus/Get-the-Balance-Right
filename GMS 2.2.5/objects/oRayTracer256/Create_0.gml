//320x240   38731, 38981, 38904, 39205, 38789

width = room_width;
height = room_height;
fov = 1.05;

show_debug_message("Go!");
time_start = current_time;

out_size = width*height;
time_step = 1000.0 / room_speed;

// 32k array workaround --->
array_max = 32000;
out_cnt = ceil(out_size/array_max);
framebuffer = array_create(0);
out = array_create(0);
for (var i=0; i<out_cnt; i++) {
    if (out_size>=array_max) {
        var size = array_max;
        out_size-=array_max;
    }
    else var size = out_size;
    for (var j=size-1; j>=0; j--) {
        framebuffer[i,j] = noone;
        out[i,j] = noone;
    }
}
out_size = width*height;
// <--- 32k array workaround

enum v {
    x,
    y,
    z
}

// materials --->
mat = instance_create_depth(x,y, 0, oMaterial);
mat_white = instance_create_depth(x,y, 0, oMaterial);
mat_white.diffuse_color = array(.3, .3, .3);
mat_orange = instance_create_depth(x,y, 0, oMaterial);
mat_orange.diffuse_color = array(.3, .2, .1);

ivory = instance_create_depth(x,y, 0, oMaterial);
ivory.refractive_index = 1.0;
ivory.albedo = array(0.9, 0.5, 0.1, 0.0); 
ivory.diffuse_color = array(0.4, 0.4, 0.3);
ivory.specular_exponent = 50.0;

glass = instance_create_depth(x,y, 0, oMaterial);
glass.refractive_index = 1.5;
glass.albedo = array(0.0, 0.9, 0.1, 0.8); 
glass.diffuse_color = array(0.6, 0.7, 0.8);
glass.specular_exponent = 125.0;

red_rubber = instance_create_depth(x,y, 0, oMaterial);
red_rubber.refractive_index = 1.0;
red_rubber.albedo = array(1.4, 0.3, 0.0, 0.0); 
red_rubber.diffuse_color = array(0.3, 0.1, 0.1);
red_rubber.specular_exponent = 10.0;

mirror = instance_create_depth(x,y, 0, oMaterial);
mirror.refractive_index = 1.0;
mirror.albedo = array(0.0, 16.0, 0.8, 0.0); 
mirror.diffuse_color = array(1.0, 1.0, 1.0);
mirror.specular_exponent = 1425.0;
// <--- materials

// spheres --->
spheres = array_create(4);

spheres[0] = instance_create_depth(x,y, 0, oSphere);
spheres[0].center = array(-3, 0, -16);
spheres[0].radius = 2;
spheres[0].material = ivory;

spheres[1] = instance_create_depth(x,y, 0, oSphere);
spheres[1].center = array(-1.0, -1.5, -12);
spheres[1].radius = 2;
spheres[1].material = glass;

spheres[2] = instance_create_depth(x,y, 0, oSphere);
spheres[2].center = array(1.5, -0.5, -18);
spheres[2].radius = 3;
spheres[2].material = red_rubber;

spheres[3] = instance_create_depth(x,y, 0, oSphere);
spheres[3].center = array(7, 5, -18);
spheres[3].radius = 4;
spheres[3].material = mirror;
// <--- spheres

// lights --->
lights = array_create(3);
lights[0] = array(-20, 20, 20);
lights[1] = array(30, 50, -25);
lights[2] = array(30, 20, 30);
// <--- lights

stage = 0;
pix = 0;

cnt = 0;
surf = noone;
draw_set_font(font0);
