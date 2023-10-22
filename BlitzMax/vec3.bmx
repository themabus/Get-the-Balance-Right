Type vec3
	Field x#,y#,z#
	
	Function Create:vec3(x#=0,y#=0,z#=0)
		Local ret:vec3 = New vec3
		ret.x=x
		ret.y=y
		ret.z=z
		Return ret
	EndFunction
	
	Method add:vec3(v:vec3)
		Local ret:vec3 = New vec3
		ret.x = x + v.x
		ret.y = y + v.y
		ret.z = z + v.z
		Return ret
	EndMethod
	
	Method sub:vec3(v:vec3)
		Local ret:vec3 = New vec3
		ret.x = x - v.x
		ret.y = y - v.y
		ret.z = z - v.z
		Return ret
	EndMethod
	
	Method inv:vec3()
		Local ret:vec3 = New vec3
		ret.x = -x
		ret.y = -y
		ret.z = -z
		Return ret
	EndMethod
	
	Method scale:vec3(n:Float)
		Local ret:vec3 = New vec3
		ret.x = x*n
		ret.y = y*n
		ret.z = z*n
		Return ret
	EndMethod
	
	Method dot:Float(v:vec3)
		Return x*v.x + y*v.y + z*v.z
	EndMethod
	
	Method norm:Float()
		Return Sqr(x*x + y*y + z*z)
	EndMethod
	
	Method normalized:vec3()
		Return Self.scale(1.0 / Self.norm())
	EndMethod
EndType
