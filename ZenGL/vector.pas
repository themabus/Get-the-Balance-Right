unit vector;

interface
type
  vec3 = record
    x,y,z: single;

    class function new(x:single = 0; y:single = 0; z:single = 0): vec3; static;
    class operator +(a,b: vec3): vec3;
    class operator -(a,b: vec3): vec3;
    class operator *(a,b: vec3): single;
    class operator -(v: vec3): vec3;
    class operator *(v: vec3; n: single): vec3;
    function norm(): single;
    function normalized(): vec3;
  end;


implementation
  class function vec3.new(x:single = 0; y:single = 0; z:single = 0): vec3;
  begin
    result.x := x;
    result.y := y;
    result.z := z;
  end;

  class operator vec3.+(a,b: vec3): vec3;
  begin
    result.x := a.x + b.x;
    result.y := a.y + b.y;
    result.z := a.z + b.z;
  end;

  class operator vec3.-(a,b: vec3): vec3;
  begin
    result.x := a.x - b.x;
    result.y := a.y - b.y;
    result.z := a.z - b.z;
  end;

  class operator vec3.*(a,b: vec3): single;
  begin
    result := a.x*b.x + a.y*b.y + a.z*b.z;
  end;

  class operator vec3.-(v: vec3): vec3;
  begin
    result.x := -v.x;
    result.y := -v.y;
    result.z := -v.z;
  end;

  class operator vec3.*(v: vec3; n: single): vec3;
  begin
    result.x := v.x * n;
    result.y := v.y * n;
    result.z := v.z * n;
  end;

  function vec3.norm(): single;
  begin
    result := sqrt(self.x*self.x + self.y*self.y + self.z*self.z);
  end;

  function vec3.normalized(): vec3;
  begin
    result := self * (1.0 / self.norm());
  end;
end.