#320x240   84151,  83899,  84196,  84014

$width = 320
$height = 240
$fov = 1.05

ray = RayTracer256.new

loop do
  ray.update
  Graphics.update
end
