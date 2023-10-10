#320x240	4327, 4294, 4325, 4289, 4266

#import sys
import math
import pygame
pygame.init()

width = 320
height = 240
fov = 1.05

#print("python" + str(sys.version))
print("pygame" + str(pygame.version.ver))
print("Go!")
time_start = pygame.time.get_ticks()

out_size = width*height
time_step = 1000.0 / 60

class Material:
    refractive_index: float = 1
    albedo = [2, 0, 0, 0]
    diffuse_color = pygame.Vector3()
    specular_exponent: float = 0

class Sphere:
    center: pygame.Vector3
    radius: float
    material: Material

framebuffer = [pygame.Vector3()] * out_size
out = [pygame.Color] * out_size

lights = [pygame.Vector3(-20, 20, 20), pygame.Vector3(30, 50, -25), pygame.Vector3(30, 20, 30)]

mat = Material()
mat_white = Material()
mat_orange = Material()
mat_white.diffuse_color = pygame.Vector3(.3, .3, .3)
mat_orange.diffuse_color = pygame.Vector3(.3, .2, .1)

ivory = Material()
ivory.refractive_index = 1.0
ivory.albedo = [0.9, 0.5, 0.1, 0.0]
ivory.diffuse_color = pygame.Vector3(0.4, 0.4, 0.3)
ivory.specular_exponent = 50.0

glass = Material()
glass.refractive_index = 1.5
glass.albedo = [0.0, 0.9, 0.1, 0.8]
glass.diffuse_color = pygame.Vector3(0.6, 0.7, 0.8)
glass.specular_exponent = 125.0

red_rubber = Material()
red_rubber.refractive_index = 1.0
red_rubber.albedo = [1.4, 0.3, 0.0, 0.0]
red_rubber.diffuse_color = pygame.Vector3(0.3, 0.1, 0.1)
red_rubber.specular_exponent = 10.0

mirror = Material()
mirror.refractive_index = 1.0
mirror.albedo = [0.0, 16.0, 0.8, 0.0]
mirror.diffuse_color = pygame.Vector3(1.0, 1.0, 1.0)
mirror.specular_exponent = 1425.0

spheres = [Sphere(), Sphere(), Sphere(), Sphere()]
spheres[0].center = pygame.Vector3(-3, 0, -16)
spheres[0].radius = 2
spheres[0].material = ivory
spheres[1].center = pygame.Vector3(-1.0, -1.5, -12)
spheres[1].radius = 2
spheres[1].material = glass
spheres[2].center = pygame.Vector3(1.5, -0.5, -18)
spheres[2].radius = 3
spheres[2].material = red_rubber
spheres[3].center = pygame.Vector3(7, 5, -18)
spheres[3].radius = 4
spheres[3].material = mirror

screen = pygame.display.set_mode((width,height))
surface = screen.copy()
screen_w = width
screen_h = height
pygame.display.set_caption("RayTracer256")
font = pygame.font.Font('freesansbold.ttf', 12)
c_white = pygame.Color(255,255,255)
label1 = font.render('your score is and always has been', True, c_white)
rect1 = label1.get_rect()
text2 = ""
label2 = font.render(text2, True, c_white)
rect2 = label2.get_rect()
rect2.y = 15

stage: int = 0
pix: int = 0
time_end = 0
fs = 0
run = True


def update():
    global pix
    global stage
    global text2
    global time_start

    t = pygame.time.get_ticks()

    if stage == 0:
        dir_z: float = -height / (2.0 * math.tan(fov / 2.0))  # const
        while pix < out_size:
            dir_x: float = (pix % width + 0.5) - width / 2.0
            dir_y: float = -(pix / width + 0.5) + height / 2.0
            framebuffer[pix] = cast_ray(pygame.Vector3(0, 0, 0), pygame.Vector3(dir_x, dir_y, dir_z).normalize())
            pix += 1
            if pygame.time.get_ticks() - t > time_step:
                text2 = str(pix)+"/"+str(out_size)
                return
        pix = 0
        stage += 1

    elif stage == 1: # unneccesary loops left in deliberately
        while pix < out_size:
            color = framebuffer[pix]
            mx: float = max(1.0, max(color.x, max(color.y, color.z)))
            out[pix] = pygame.Color(int(255*color.x / mx), int(255*color.y / mx), int(255*color.z / mx))
            pix += 1
            if pygame.time.get_ticks() - t > time_step:
                text2 = str(out_size) + "/" + str(out_size)
                return
        stage += 1
        time_end = pygame.time.get_ticks() - time_start
        print(time_end)
        text2 = str(time_end)


def draw():
    global stage
    global height
    global width
    global text2
    global screen_w
    global screen_h

    if stage == 0 or stage == 1:
        surface.fill((30, 31, 34))
        label2 = font.render(text2, True, c_white)
        surface.blit(label2, rect2)
    elif stage == 2:
        pix = 0
        for i in range(height):
            for j in range(width):
                surface.set_at((j, i), out[pix])
                pix += 1
        surface.blit(label1, rect1)
        label2 = font.render(text2, True, c_white)
        surface.blit(label2, rect2)
        stage += 1
    screen.blit(pygame.transform.scale(surface, (screen_w, screen_h)), (0, 0))
    pygame.display.update()


def cast_ray(orig: pygame.Vector3, dir: pygame.Vector3, depth: int = 0):
    hit, point, N, material = scene_intersect(orig, dir)

    if depth > 4 or not hit:
        return pygame.Vector3(0.2, 0.7, 0.8)  # background color

    reflect_dir = reflect(dir, N).normalize()
    refract_dir = refract(dir, N, material.refractive_index).normalize()
    reflect_color = cast_ray(point, reflect_dir, depth + 1)
    refract_color = cast_ray(point, refract_dir, depth + 1)

    diffuse_light_intensity: float = 0
    specular_light_intensity: float = 0

    for light in lights:  # checking if the point lies in the shadow of the light
        light_dir: pygame.Vector3 = (light - point).normalize()
        hit, shadow_pt, dummy1, dummy2 = scene_intersect(point, light_dir)
        if (hit and (shadow_pt - point).length() < (light - point).length()): continue
        diffuse_light_intensity += max(0.0, light_dir.dot(N))
        specular_light_intensity += pow(max(0.0, -reflect(-light_dir, N).dot(dir)), material.specular_exponent)

    return (material.diffuse_color * diffuse_light_intensity * material.albedo[0] + pygame.Vector3(1.0, 1.0, 1.0)
            * specular_light_intensity * material.albedo[1] + reflect_color * material.albedo[2] + refract_color * material.albedo[3])


def scene_intersect(orig: pygame.Vector3, dir: pygame.Vector3):
    pt = pygame.Vector3(0,0,0)
    N = pygame.Vector3(0,0,0)
    material = Material()

    nearest_dist: float = 1e10
    if abs(dir.y) > .001:  # intersect the ray with the checkerboard, avoid division by zero
        d: float = -(orig.y + 4) / dir.y  # the checkerboard plane has equation y = -4
        p: pygame.Vector3 = orig + dir * d
        if (d > .001 and d < nearest_dist and abs(p.x) < 10 and p.z < -10 and p.z > -30):
            nearest_dist = d
            pt = p
            N = pygame.Vector3(0, 1, 0)
            material = mat_white if (int(.5 * pt.x + 1000) + int(.5 * pt.z)) & 1 else mat_orange

    for s in spheres:  # intersect the ray with all spheres
        intersection, d = ray_sphere_intersect(orig, dir, s)
        if (not intersection or d > nearest_dist): continue
        nearest_dist = d
        pt = orig + dir * nearest_dist
        N = (pt - s.center).normalize()
        material = s.material

    return nearest_dist < 1000, pt, N, material


def ray_sphere_intersect(orig: pygame.Vector3, dir: pygame.Vector3, s: Sphere):	# ret value is a pair [intersection found, distance]
    L: pygame.Vector3 = s.center - orig
    tca: float = L.dot(dir)
    d2: float = L.dot(L) - tca * tca
    if (d2 > s.radius * s.radius): return False, 0
    thc: float = math.sqrt(s.radius * s.radius - d2)
    t0: float = tca - thc
    t1: float = tca + thc
    if (t0 > .001): return True, t0
    if (t1 > .001): return True, t1

    return False, 0


def reflect(I: pygame.Vector3, N: pygame.Vector3):
    return I - N * 2.0 * I.dot(N)


def refract(I: pygame.Vector3, N: pygame.Vector3, eta_t: float, eta_i: float = 1.0):	# Snell's law
    cosi: float = -max(-1.0, min(1.0, I.dot(N)))
    if (cosi < 0): return refract(I, -N, eta_i, eta_t)  # if the ray comes from the inside the object, swap the air and the media
    eta: float = eta_i / eta_t
    k: float = 1 - eta * eta * (1 - cosi * cosi)

    return pygame.Vector3(1, 0, 0) if k < 0 else I * eta + N * (eta * cosi - math.sqrt(k))  # k<0 = total reflection, no ray to refract. I refract it anyways, this has no physical meaning


while run:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            run = False
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_ESCAPE:    # Quit
                run = False
            elif event.key == pygame.K_RETURN and pygame.key.get_mods() & pygame.KMOD_ALT:  # FullScreen
                fs += 1
                if fs % 2:
                    pygame.display.set_mode((width,height),pygame.FULLSCREEN)
                else:
                    pygame.display.set_mode((width, height))
                io = pygame.display.Info()
                screen_w = io.current_w
                screen_h = io.current_h
    update()
    draw()


pygame.quit()
quit()
