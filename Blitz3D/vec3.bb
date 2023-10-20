Type vec3
	Field x#,y#,z#
End Type

Function vec3.vec3(x#=0,y#=0,z#=0)
	v.vec3 = New vec3
	v\x=x
	v\y=y
	v\z=z
	Return v
End Function 

Function vec3_add.vec3(a.vec3,b.vec3)
	Return vec3(a\x+b\x, a\y+b\y, a\z+b\z)
End Function

Function vec3_sub.vec3(a.vec3,b.vec3)
	Return vec3(a\x-b\x, a\y-b\y, a\z-b\z)
End Function

Function vec3_inv.vec3(v.vec3)
	Return vec3(-v\x, -v\y, -v\z)
End Function

Function vec3_scale.vec3(v.vec3,n#)
	Return vec3(v\x*n#, v\y*n#, v\z*n#)
End Function

Function vec3_dot#(a.vec3,b.vec3)
	Return a\x*b\x + a\y*b\y + a\z*b\z
End Function

Function vec3_norm#(v.vec3)
	Return Sqr(v\x*v\x + v\y*v\y + v\z*v\z)
End Function

Function vec3_normalized.vec3(v.vec3)
	Return vec3_scale(v, 1.0 / vec3_norm(v))
End Function
