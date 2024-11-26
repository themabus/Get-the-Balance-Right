#320x240   19110,  19056,  19146,  19076

$width = 320
$height = 240
$fov = 1.05

ray = RayTracer256.new

loop do
  ray.update
  Graphics.update
end
