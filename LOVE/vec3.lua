vec3 = {}
vec3.__index = vec3

function vec3.new(x, y, z)
    return setmetatable({x = x or 0, y = y or 0, z = z or 0}, vec3)
end

function vec3:norm()
    return math.sqrt(self.x*self.x + self.y*self.y + self.z*self.z)
end

function vec3:normalized()
    local n = 1.0 / self:norm()
    return vec3.new(self.x * n, self.y * n, self.z * n)
end

function vec3.__mul(a, b)
    if type(b) == "table" then
        return a.x*b.x + a.y*b.y + a.z*b.z
    else
        return vec3.new(a.x*b, a.y*b, a.z*b)
    end
end

function vec3.__add(a, b)
    return vec3.new(a.x + b.x, a.y + b.y, a.z + b.z)
end

function vec3.__sub(a, b)
    return vec3.new(a.x - b.x, a.y - b.y, a.z - b.z)
end

function vec3.__unm(v)
    return vec3.new(-v.x, -v.y, -v.z)
end

function vec3.__tostring(v)
    return "(" .. v.x .. ", " .. v.y .. ", " .. v.z .. ")"
end
