Class vec3
	Field x:Float,y:Float,z:Float
	
	Method New(x#=0,y#=0,z#=0)
		Self.x = x
		Self.y = y
		Self.z = z
	End Method
	
	Method add:vec3(v:vec3)
		Local ret:vec3 = New vec3
		ret.x = x + v.x
		ret.y = y + v.y
		ret.z = z + v.z
		Return ret
	End Method
	
	Method sub:vec3(v:vec3)
		Local ret:vec3 = New vec3
		ret.x = x - v.x
		ret.y = y - v.y
		ret.z = z - v.z
		Return ret
	End Method
	
	Method inv:vec3()
		Local ret:vec3 = New vec3
		ret.x = -x
		ret.y = -y
		ret.z = -z
		Return ret
	End Method
	
	Method scale:vec3(n:Float)
		Local ret:vec3 = New vec3
		ret.x = x*n
		ret.y = y*n
		ret.z = z*n
		Return ret
	End Method
	
	Method dot:Float(v:vec3)
		Return x*v.x + y*v.y + z*v.z
	End Method
	
	Method norm:Float()
		Return Sqrt(x*x + y*y + z*z)
	End Method
	
	Method normalized:vec3()
		Return Self.scale(1.0 / Self.norm())
	End Method
End Class
