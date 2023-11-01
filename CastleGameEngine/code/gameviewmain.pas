//320x240	  205,   212,   203,   199,   200
unit GameViewMain;

interface

uses Classes,
  CastleVectors, CastleComponentSerialize,
  CastleUIControls, CastleControls, CastleKeysMouse;

type
  { Main view, where most of the application logic takes place. }
  TViewMain = class(TCastleView)
  published
    { Components designed using CGE editor.
      These fields will be automatically initialized at Start. }
  public
    constructor Create(AOwner: TComponent); override;
    procedure Start; override;
    procedure Update(const SecondsPassed: Single; var HandleInput: Boolean); override;
    function Press(const Event: TInputPressRelease): Boolean; override;
    procedure Render; override;
  end;

var
  ViewMain: TViewMain;

implementation

uses 
  SysUtils,
  Math,
  vector,
  CastleTimeUtils,
  CastleImages,
  CastleGLImages,
  CastleColors;

const
  ww  = 320;
  hh  = 240;
  fov = 1.05;// 60 degrees field of view in radians

type
  Material = record
    refractive_index: single;
    albedo: array[0..3] of single;
    diffuse_color: vec3;
    specular_exponent: integer;
  end;
  pMaterial = ^Material;

  Sphere = record
    center: vec3;
    radius: single;
    material: pMaterial;
  end;

  ret_scene = record
    hit: boolean;
    point: vec3;
    N: vec3;
    material: Material;
  end;

  ret_sphere = record
    hit: boolean;
    dist: single;
  end;

const
  ivory: Material = (
    refractive_index: 1.0;
    albedo: (0.9, 0.5, 0.1, 0.0);
    diffuse_color: (x:0.4; y:0.4; z:0.3);
    specular_exponent: 50;
  );
  glass: Material = (
    refractive_index: 1.5;
    albedo: (0.0, 0.9, 0.1, 0.8);
    diffuse_color: (x:0.6; y:0.7; z:0.8);
    specular_exponent: 125;
  );
  red_rubber: Material = (
    refractive_index: 1.0;
    albedo: (1.4, 0.3, 0.0, 0.0);
    diffuse_color: (x:0.3; y:0.1; z:0.1);
    specular_exponent: 10;
  );
  mirror: Material = (
    refractive_index: 1.0;
    albedo: (0.0, 16.0, 0.8, 0.0);
    diffuse_color: (x:1.0; y:1.0; z:1.0);
    specular_exponent: 1425;
  );
  mat: Material = (
    refractive_index: 1.0;
    albedo: (2, 0, 0, 0);
    diffuse_color: (x:0; y:0; z:0);
    specular_exponent: 0;
  );
  mat_white: Material = (
    refractive_index: 1.0;
    albedo: (2, 0, 0, 0);
    diffuse_color: (x:0.3; y:0.3; z:0.3);
    specular_exponent: 0;
  );
  mat_orange: Material = (
    refractive_index: 1.0;
    albedo: (2, 0, 0, 0);
    diffuse_color: (x:0.3; y:0.2; z:0.1);
    specular_exponent: 0;
  );


const
  spheres: array[0..3] of Sphere = (
    (center: (x:-3;   y: 0;   z:-16); radius: 2; material: @ivory),
    (center: (x:-1.0; y:-1.5; z:-12); radius: 2; material: @glass),
    (center: (x: 1.5; y:-0.5; z:-18); radius: 3; material: @red_rubber),
    (center: (x: 7;   y: 5;   z:-18); radius: 4; material: @mirror)
  );
  lights: array[0..2] of vec3 = (
    (x:-20; y:20; z: 20),
    (x: 30; y:50; z:-25),
    (x: 30; y:20; z: 30)
  );

  fps = 60;
  out_size = ww * hh;
  time_step = 1000.0 / fps;

var
  stage: integer = 0;
  pix: integer = 0;

  zero: vec3;
  fs: boolean = false;
  time_start: single;
  time_end: single = 0;
  framebuffer: array[0..out_size] of vec3;
  o: array[0..out_size] of tvector3;
  label1: string = 'your score is and always has been';
  image: TRGBImage;
  dimage: TDrawableImage;

{ TViewMain ----------------------------------------------------------------- }

constructor TViewMain.Create(AOwner: TComponent);
begin
  inherited;
  DesignUrl := 'castle-data:/gameviewmain.castle-user-interface';

  time_start := CastleGetTickCount64;
  image := TRGBImage.Create(ww,hh);
  dimage := TDrawableImage.Create(image, false, true);
end;


procedure TViewMain.Start;
begin
  inherited;
end;


function reflect(I:vec3; N:vec3): vec3;
begin
  result := I - (N * 2.0*(I*N));
end;


function refract(I:vec3; N:vec3; eta_t:single; eta_i:single = 1.0): vec3;// Snell's law
var
  cosi,eta,k: single;
begin
  cosi := -max(-1.0, Min(1.0, I*N));
  if cosi<0 then exit(refract(I, -N, eta_i, eta_t));// If the ray comes from the inside the Object, swap the air And the media
  eta := eta_i / eta_t;
  k := 1 - eta*eta*(1 - cosi*cosi);
  if k<0 then exit(vec3.new(1,0,0))
  else result := I*eta + N*(eta*cosi - sqrt(k));// k<0 = total reflection, no ray to refract. I refract it anyways, this has no physical meaning
end;


function ray_sphere_intersect(orig:vec3; dir:vec3; s:Sphere): ret_sphere;// ret value is a pair [intersection found, distance]
var
  L: vec3;
  tca,thc,d2,t0,t1: float;
begin
  result.hit := false;
  result.dist := 0;

  L := s.center - orig;
  tca := L * dir;
  d2 := L*L - tca*tca;
  if d2 > s.radius*s.radius then exit;
  thc := sqrt(s.radius*s.radius - d2);
  t0 := tca-thc;
  t1 := tca+thc;
  If t0>0.001 then begin// offset the original point by .001 To avoid occlusion by the Object itself
    result.hit := true;
    result.dist := t0;
    exit;
  end;
  if t1>0.001 then begin
    result.hit := true;
    result.dist := t1;
    exit;
  end;
end;


function scene_intersect(orig:vec3; dir:vec3): ret_scene;
var
  nearest_dist: single = 1e10;
  d: single;
  p: vec3;
  i: integer;
  sphere: ret_sphere;
begin
  result.material := mat;
  result.point := vec3.new();
  result.N := vec3.new();

  if abs(dir.y)>0.001 then begin// intersect the ray with the checkerboard, avoid division by zero
    d := -(orig.y+4)/dir.y;// the checkerboard plane has equation y = -4
    p := orig + dir * d;
    if (d>0.001) and (d<nearest_dist) and (abs(p.x)<10) and (p.z<-10) and (p.z>-30) then begin
      nearest_dist := d;
      result.point := p;
      result.N.y := 1;
      if (floor(0.5*result.point.x+1000) + floor(0.5*result.point.z)) and 1 = 0 then result.material := mat_white else result.material := mat_orange;
    end;
  end;

  for i:=0 to length(spheres)-1 do begin// intersect the ray with all spheres
    sphere := ray_sphere_intersect(orig, dir, spheres[i]);
    if (sphere.hit=false) or (sphere.dist > nearest_dist) then continue;
    nearest_dist := sphere.dist;
    result.point := orig + dir*nearest_dist;
    result.N := (result.point - spheres[i].center).normalized();
    result.material := spheres[i].material^;
  end;

  result.hit := nearest_dist<1000;
end;


function cast_ray(orig:vec3; dir:vec3; depth:integer = 0): vec3;
var
  scene, shadow: ret_scene;
  reflect_dir: vec3;
  refract_dir: vec3;
  reflect_color: vec3;
  refract_color: vec3;
  diffuse_light_intensity: single;
  specular_light_intensity: single;
  i: integer;
  light_dir: vec3;
  f1, f2: single;
  v1, v2, v3, v4: vec3;
begin
  scene := scene_intersect(orig, dir);
  if (depth>4) or (not scene.hit) then begin
    exit (vec3.new(0.2, 0.7, 0.8));// background color
  end;

  reflect_dir := reflect(dir, scene.N).normalized();
  refract_dir := refract(dir, scene.N, scene.material.refractive_index).normalized();
  reflect_color := cast_ray(scene.point, reflect_dir, depth + 1);
  refract_color := cast_ray(scene.point, refract_dir, depth + 1);

  diffuse_light_intensity := 0;
  specular_light_intensity := 0;

  for i:=0 to length(lights)-1 do begin// checking If the point lies in the shadow of the light
    light_dir := (lights[i] - scene.point).normalized();
    shadow := scene_intersect(scene.point, light_dir);
    if (shadow.hit) and ((shadow.point - scene.point).norm() < (lights[i] - scene.point).norm()) then continue;
    diffuse_light_intensity += max(0.0, light_dir * scene.N);
    specular_light_intensity += power(max(0.0, -reflect(-light_dir, scene.N)*dir), scene.material.specular_exponent);
  end;

  f1 := diffuse_light_intensity * scene.material.albedo[0];
  f2 := specular_light_intensity * scene.material.albedo[1];
  v1 := scene.material.diffuse_color * f1;
  v2 := vec3.new(f2, f2, f2);
  v3 := reflect_color * scene.material.albedo[2];
  v4 := refract_color * scene.material.albedo[3];
  result := v1 + v2 + v3 + v4;
end;


procedure TViewMain.Update(const SecondsPassed: Single; var HandleInput: Boolean);
var
  t: single;
  dir_x, dir_y, dir_z: single;
  mx: single;
  i,j: integer;
begin
  inherited;
  { This virtual method is executed every frame (many times per second). }

  t := CastleGetTickCount64;

  case stage of
    0: begin
      zero := vec3.new();
      dir_z := -hh/(2.0*tan(fov/2.0));// Const
      while (pix < out_size) do begin// actual rendering loop
        dir_x := (pix mod ww + 0.5) - ww/2.0;
        dir_y := -(pix div floor(ww) + 0.5) + hh/2.0;// this flips the image at the same time
        framebuffer[pix] := cast_ray(zero, vec3.new(dir_x, dir_y, dir_z).normalized());
        pix+=1;
        if CastleGetTickCount64 - t > time_step then exit;
      end;
      pix:=0;
      stage+=1;
    end;
    1: begin// unneccesary loops left in deliberately
      while (pix < out_size) do begin
        mx := max(1.0, max(framebuffer[pix].x, max(framebuffer[pix].y, framebuffer[pix].z)));
        o[pix] := Vector3(framebuffer[pix].x/mx, framebuffer[pix].y/mx, framebuffer[pix].z/mx);
        pix+=1;
        if CastleGetTickCount64 - t > time_step then exit;
      end;
      pix:=0;
      stage+=1;
      time_end := CastleGetTickCount64 - time_start;
    end;
    2: begin
      for i:=0 to hh-1 do begin
        for j:=0 to ww-1 do begin
          image.SetColorRGB(j, i, o[pix]);
          pix+=1;
        end;
      end;
      image.FlipVertical;
      dimage := TDrawableImage.Create(image, false, true);
      stage+=1;
    end;
  end;
end;


procedure TViewMain.Render;
var
  text1,text2: string;
begin
  case stage of
    0: begin
      str(pix, text1);
      str(out_size, text2);
      UIFont.Print(0,ViewMain.ContainerHeight-40, White, text1+'/'+text2);
    end;
    1,2: begin
      str(out_size, text1);
      UIFont.Print(0,ViewMain.ContainerHeight-40, White, text1+'/'+text1);
    end;
    else begin
      str(floor(time_end), text1);
      dimage.draw(0,0, ViewMain.ContainerWidth,ViewMain.ContainerHeight);
      UIFont.Print(0,ViewMain.ContainerHeight-20, White, label1);
      UIFont.Print(0,ViewMain.ContainerHeight-40, White, text1);
    end;
  end;
end;


function TViewMain.Press(const Event: TInputPressRelease): Boolean;
begin
  Result := inherited;
  if Result then Exit; // allow the ancestor to handle keys

  { This virtual method is executed when user presses
    a key, a mouse button, or touches a touch-screen.

    Note that each UI control has also events like OnPress and OnClick.
    These events can be used to handle the "press", if it should do something
    specific when used in that UI control.
    The TViewMain.Press method should be used to handle keys
    not handled in children controls.
  }

  // Use this to handle keys:
  {
  if Event.IsKey(keyXxx) then
  begin
    // DoSomething;
    Exit(true); // key was handled
  end;
  }
end;


end.
