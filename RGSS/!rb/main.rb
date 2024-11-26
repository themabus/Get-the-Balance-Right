#320x240  109314, 108483, 108981, 107838

$width = 320
$height = 240
$fov = 1.05

ray = RayTracer256.new

loop do
  ray.update
  Graphics.update
end
