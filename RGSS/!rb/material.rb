class Material
#============================================================================
  attr_accessor :refractive_index
  attr_accessor :albedo
  attr_accessor :diffuse_color
  attr_accessor :specular_exponent
  #--------------------------------------------------------------------------
  def initialize
    @refractive_index = 1.to_f
    @albedo = Array[2, 0, 0, 0]
    @diffuse_color = Vec3.new(0, 0, 0)
    @specular_exponent = 0.to_f
  end
#============================================================================
end
