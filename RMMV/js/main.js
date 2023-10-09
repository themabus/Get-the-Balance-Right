//320x240    2089, 2078, 2218, 2220, 2234, 2198

var width = 320;
var height = 240;
var fov = 1.05;

console.log("Go!");
time_start = Date.now();

var out_size = width*height;
var time_step = 1000.0 / 60.0;

class Vector {
    constructor(...v) {
        this.v = v;
    }

    add({ v }) {
        return new Vector(
            ...v.map((v, i) => this.v[i] + v)
        )
    }
    sub({ v }) {
        return new Vector(
            ...v.map((v, i) => this.v[i] - v)
        )
    }
    dot({ v }) {
        return v.reduce((acc, v, i) => acc + v * this.v[i], 0)
    }
    inv() {
        return new Vector(
            ...this.v.map((v, i) => -this.v[i])
        )
    }
    scale(n) {
        return new Vector(
          ...this.v.map(v => v * n)
        )
    }
    norm() {
        return Math.sqrt(this.v.reduce((acc, v, i) => acc + v * this.v[i], 0))
    }
    normalized() {
        return this.scale(1.0 / this.norm())
    }
}

class Material {
    constructor(){
        this.refractive_index = 1.0;
        this.albedo = [2, 0, 0, 0]
        this.diffuse_color = new Vector(0,0,0);
        this.specular_exponent = 0.0;
    }
}

class Sphere {
    constructor(){
        this.center = null;
        this.radius = null;
        this.material = null;
    }
}

var lights = [new Vector(-20, 20, 20), new Vector(30, 50, -25), new Vector(30, 20, 30)];

var mat = new Material();
var mat_white = new Material();
var mat_orange = new Material();

var ivory = new Material();
ivory.refractive_index = 1.0;
ivory.albedo = [0.9, 0.5, 0.1, 0.0];
ivory.diffuse_color = new Vector(0.4, 0.4, 0.3);
ivory.specular_exponent = 50.0;

var glass = new Material();
glass.refractive_index = 1.5;
glass.albedo = [0.0, 0.9, 0.1, 0.8];
glass.diffuse_color = new Vector(0.6, 0.7, 0.8);
glass.specular_exponent = 125.0;

var red_rubber = new Material();
red_rubber.refractive_index = 1.0;
red_rubber.albedo = [1.4, 0.3, 0.0, 0.0];
red_rubber.diffuse_color = new Vector(0.3, 0.1, 0.1);
red_rubber.specular_exponent = 10.0;

var mirror = new Material();
mirror.refractive_index = 1.0;
mirror.albedo = [0.0, 16.0, 0.8, 0.0];
mirror.diffuse_color = new Vector(1.0, 1.0, 1.0);
mirror.specular_exponent = 1425.0;

var spheres = [new Sphere(), new Sphere(), new Sphere(), new Sphere()];
spheres[0].center = new Vector(-3, 0, -16);
spheres[0].radius = 2;
spheres[0].material = ivory;
spheres[1].center = new Vector(-1.0, -1.5, -12);
spheres[1].radius = 2;
spheres[1].material = glass;
spheres[2].center = new Vector(1.5, -0.5, -18);
spheres[2].radius = 3;
spheres[2].material = red_rubber;
spheres[3].center = new Vector(7, 5, -18);
spheres[3].radius = 4;
spheres[3].material = mirror;

var framebuffer = new Array(out_size);
var out = new Array(out_size);

mat_white.diffuse_color = new Vector(.3, .3, .3);
mat_orange.diffuse_color = new Vector(.3, .2, .1);

var stage = 0;
var pix = 0;

document.body.style.margin = 0;
var canvas = document.createElement("canvas");
var screen = document.createElement("canvas");
canvas.width = width;
canvas.height = height;
screen.width = window.innerWidth;
screen.height = window.innerHeight;
canvas.id = "canvas";
screen.id = "screen";
document.body.appendChild(screen);
var ctx = canvas.getContext("2d");
var canvasData = ctx.getImageData(0, 0, width, height);
var stx = screen.getContext("2d");
var screenData = stx.getImageData(0, 0, width, height);
var image = new Image();

window.addEventListener('resize', canvas_resize, false);
setInterval(update, time_step);


function draw_rgb(x,y, r,g,b,a) {
    var idx = (x + y * width) * 4;
    canvasData.data[idx + 0] = r;
    canvasData.data[idx + 1] = g;
    canvasData.data[idx + 2] = b;
    canvasData.data[idx + 3] = a;
}


function canvas_update() {
    ctx.putImageData(canvasData, 0, 0);
}


function canvas_resize() {
    screen.width = document.body.clientWidth;
    screen.height = window.innerHeight-4;
    stx.imageSmoothingEnabled = false;
    stx.drawImage(image, 0,0, window.innerWidth,window.innerHeight);
}


function update() {
    var t = Date.now();

    switch(stage) {
        case 0:
            var dir_z = -height/(2.0*Math.tan(fov/2.0)); // const
            while (pix < out_size) {
                var dir_x = (pix%width + 0.5) -  width/2.0;
                var dir_y = -(pix/width + 0.5) + height/2.0;
                framebuffer[pix] = cast_ray(new Vector(0,0,0), new Vector(dir_x,dir_y,dir_z).normalized());
                pix+=1;
                if (Date.now() - t > time_step) {
                    ctx.fillStyle = 'black';
                    ctx.fillRect(0,0, width,height);
                    ctx.fillStyle = 'white';
                    ctx.fillText('your score is and always has been', 4, 10);
                    var str = pix.toString();
                    ctx.fillText(pix.toString()+'/'+out_size.toString(), 4, 20);
                    image.src = canvas.toDataURL();
                    stx.drawImage(image, 0,0, document.body.clientWidth,window.innerHeight-4);
                    return
                }
            }
            pix = 0;
            stage += 1;
        break;

        case 1: // unneccesary loops left in deliberately
            while(pix < out_size) {
                var color = framebuffer[pix];
                var mx = Math.max(1.0, Math.max(color.v[0], Math.max(color.v[1], color.v[2])));
                out[pix] = [255*color.v[0]/mx, 255*color.v[1]/mx, 255*color.v[2]/mx];
                pix+=1;
                if (Date.now() - t > time_step) {
                    return
                }
            }
            stage += 1;
            time_end = Date.now() - time_start;
            console.log(time_end);
        break;

        case 2:
            pix = 0;
            for (var i = 0; i < height; i++) {
                for (var j = 0; j < width; j++) {
                    draw_rgb(j,i, out[pix][0], out[pix][1], out[pix][2], 255);
                    pix ++;
                }
            }
            canvas_update();
            ctx.fillStyle = 'white';
            ctx.fillText('your score is and always has been', 4, 10);
            ctx.fillText(time_end.toString(), 4, 20);
            stx.imageSmoothingEnabled = false;
            image.src = canvas.toDataURL();
            stage++;
        break;
    }
    stx.drawImage(image, 0,0, document.body.clientWidth,window.innerHeight-4);
}


function cast_ray(orig, dir, depth = 0) {
    var tmp = scene_intersect(orig, dir);
    var hit = tmp[0]; var point = tmp[1]; var N = tmp[2]; var material = tmp[3];

    if (depth>4 || !hit)
        return new Vector(0.2, 0.7, 0.8); // background color

    var reflect_dir = reflect(dir, N).normalized();
    var refract_dir = refract(dir, N, material.refractive_index).normalized();
    var reflect_color = cast_ray(point, reflect_dir, depth + 1);
    var refract_color = cast_ray(point, refract_dir, depth + 1);

    var diffuse_light_intensity = 0;
    var specular_light_intensity = 0;

    for (const light of lights) { // checking if the point lies in the shadow of the light
        var light_dir = light.sub(point).normalized();
        tmp = scene_intersect(point, light_dir);
        hit = tmp[0]; var shadow_pt = tmp[1];
        if ( hit && shadow_pt.sub(point).norm() < light.sub(point).norm() ) continue;
        diffuse_light_intensity += Math.max(0., light_dir.dot(N));
        specular_light_intensity += Math.pow(Math.max(0., reflect(light_dir.inv(), N).inv().dot(dir)), material.specular_exponent);
    }
    var tmp1 = material.diffuse_color.scale(diffuse_light_intensity * material.albedo[0]);
    var tmp2 = specular_light_intensity * material.albedo[1];
    tmp2 = new Vector(tmp2, tmp2, tmp2);
    var tmp3 = reflect_color.scale(material.albedo[2]);
    var tmp4 = refract_color.scale(material.albedo[3]);
    
    return tmp1.add(tmp2).add(tmp3).add(tmp4);
}


function scene_intersect(orig, dir) {
    var pt = new Vector();
    var N = new Vector();
    var material = new Material();

    var nearest_dist = 1e10;
    if (Math.abs(dir.v[1])>0.001) { // intersect the ray with the checkerboard, avoid division by zero
        var d = -(orig.v[1]+4)/dir.v[1]; // the checkerboard plane has equation y = -4
        var p = orig.add(dir.scale(d));
        if (d>.001 && d<nearest_dist && Math.abs(p.v[0])<10 && p.v[2]<-10 && p.v[2]>-30) {
            nearest_dist = d;
            pt = p;
            N = new Vector(0,1,0);
            material.diffuse_color = (parseInt(.5*pt.v[0]+1000) + parseInt(.5*pt.v[2])) & 1 ? new Vector(.3, .3, .3) : new Vector(.3, .2, .1);
        }
    }

    var tmp;
    for (const s of spheres) {	// intersect the ray with all spheres
        tmp = ray_sphere_intersect(orig, dir, s);
        var intersection = tmp[0];
        var d = tmp[1];
        if (!intersection || d > nearest_dist) continue
        nearest_dist = d;
        pt = orig.add(dir.scale(nearest_dist));
        N = pt.sub(s.center).normalized();
        material = s.material;
    }

    return [nearest_dist < 1000, pt, N, material];
}


function ray_sphere_intersect(orig, dir, s) { // ret value is a pair [intersection found, distance]
    var L = s.center.sub(orig);
    var tca = L.dot(dir);
    var d2 = L.dot(L) - tca*tca;
    if (d2 > s.radius*s.radius) return [false, 0]
    var thc = Math.sqrt(s.radius*s.radius - d2);
    var t0 = tca-thc;
    var t1 = tca+thc;
    if (t0>.001) return [true, t0]
    if (t1>.001) return [true, t1]

    return [false, 0]
}


function reflect(I, N) {
    return I.sub(N.scale(2.0 * I.dot(N)))
}


function refract(I, N, eta_t, eta_i = 1.0) { // Snell's law
    var cosi = -Math.max(-1.0, Math.min(1.0, I.dot(N)));
    if (cosi<0) return refract(I, N.inv(), eta_i, eta_t) // if the ray comes from the inside the object, swap the air and the media
    var eta = eta_i / eta_t;
    var k = 1 - eta*eta*(1 - cosi*cosi);

    return (k<0) ? new Vector(1,0,0) : I.scale(eta).add(N.scale(eta*cosi - Math.sqrt(k))) // k<0 = total reflection, no ray to refract. I refract it anyways, this has no physical meaning
}
