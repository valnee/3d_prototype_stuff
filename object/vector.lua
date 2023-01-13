local vector = {}
vector.__index = vector

local SQRT = math.sqrt

local scale_matrice          = require "matrices.scale"
local translate_matrice      = require "matrices.translate"
local euler_rotation_matrice = require "matrices.euler_rotation"
local matmul                 = require "matrices.matmul"

function vector.new(x,y,z)
    local self = setmetatable({}, vector)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
    self.w = 1
    return self
end

function vector.__add(a,b)
    if type(a) == "number" then
        return vector.new(b.x+a, b.y+a, b.z+a)
    elseif type(b) == "number" then
        return vector.new(a.x+b, a.y+b, a.z+b)
    else
        return vector.new(a.x+b.x, a.y+b.y, a.z+b.z)
    end
end

function vector.__sub(a,b)
    if type(a) == "number" then
        return vector.new(b.x-a, b.y-a, b.z-a)
    elseif type(b) == "number" then
        return vector.new(a.x-b, a.y-b, a.z-b)
    else
        return vector.new(a.x-b.x, a.y-b.y, a.z-b.z)
    end
end

function vector.__mul(a,b)
    if type(a) == "number" then
        return vector.new(b.x*a, b.y*a, b.z*a)
    elseif type(b) == "number" then
        return vector.new(a.x*b, a.y*b, a.z*b)
    else
        return vector.new(a.x*b.x, a.y*b.y, a.z*b.z)
    end
end

function vector.__div(a,b)
    if type(a) == "number" then
        return vector.new(b.x/a, b.y/a, b.z/a)
    elseif type(b) == "number" then
        return vector.new(a.x/b, a.y/b, a.z/b)
    else
        return vector.new(a.x/b.x, a.y/b.y, a.z/b.z)
    end
end

function vector.__mod(a,b)
    if type(a) == "number" then
        return vector.new(b.x%a, b.y%a, b.z%a)
    elseif type(b) == "number" then
        return vector.new(a.x%b, a.y%b, a.z%b)
    else
        return vector.new(a.x%b.x, a.y%b.y, a.z%b.z)
    end
end

function vector.__pow(a,b)
    if type(a) == "number" then
        return vector.new(b.x^a, b.y^a, b.z^a)
    elseif type(b) == "number" then
        return vector.new(a.x^b, a.y^b, a.z^b)
    else
        return vector.new(a.x^b.x, a.y^b.y, a.z^b.z)
    end
end

function vector.__eq(a,b) return (a.x==b.x) and (a.y==b.y) and (a.z==b.z) end
function vector.__lt(a,b) return (a.x<b.x)  and (a.y<b.y)  and (a.z<b.z)  end
function vector.__le(a,b) return (a.x<=b.x) and (a.y<=b.y) and (a.z<=b.z) end
function vector.__unm(a)  return vector.new(-a.x, -a.y, -a.z) end
function vector.__len(a)  return a:length() end

function vector.distance(a,b)  local v=b-a return v:length() end
function vector:length()       return SQRT(self.x*self.x + self.y*self.y + self.z*self.z) end
function vector:normalize()
    local leng = self:length()
    if leng > 0 then
        return vector.new(self.x/leng, self.y/leng, self.z/leng)
    end
    return self
end
function vector.cross(a,b)
    return vector.new(
        a.y*b.z - a.z*b.y,
        a.z*b.x - a.x*b.z,
        a.x*b.y - a.y*b.x
    ) 
end
function vector.dot(a,b)       return (a.x*b.x + a.y*b.y + a.z*b.z) end
function vector:scale(vec, a)     self.x, self.y, self.z, self.w = matmul(self.x, self.y, self.z, self.w, scale_matrice(vec.x,vec.y,vec.z), a)          return self end
function vector:rotate(vec, a)    self.x, self.y, self.z, self.w = matmul(self.x, self.y, self.z, self.w, euler_rotation_matrice(vec.x,vec.y,vec.z), a) return self end
function vector:translate(vec, a) self.x, self.y, self.z, self.w = matmul(self.x, self.y, self.z, self.w, translate_matrice(vec.x, vec.y, vec.z), a)    return self end
function vector:lookat(from, to, up)
    local n = (from - to):normalize()
    local u = vector.cross(up, n):normalize()
    local v = vector.cross(n, u):normalize()

    self.x,self.y,self.z,self.w = matmul(self.x, self.y, self.z, self.w, {
        u.x,v.x,n.x,0,
        u.y,v.y,n.y,0,
        u.z,v.z,n.z,0,
        -vector.dot(from, u),
        -vector.dot(from, v),
        -vector.dot(from, n),1
    })
    return self
end
function vector:print()    print("x:" .. tostring(self.x) .. " y:" .. tostring(self.y) .. " z:" .. tostring(self.z)) end
function vector:clone()    return vector.new(self.x, self.y, self.z) end
function vector.zeros()    return vector.new(0,0,0) end
function vector.ones()     return vector.new(1,1,1) end
function vector.up()       return vector.new(0,1,0) end
function vector.down()     return vector.new(0,-1,0) end
function vector.left()     return vector.new(-1,0,0) end
function vector.right()    return vector.new(1,0,0) end
function vector.forward()  return vector.new(0,0,1) end
function vector.backward() return vector.new(0,0,-1) end
function vector.random(xf,xt, yf,yt, zf,zt)   return vector.new(
    math.random(xf or -1000, xt or 1000),
    math.random(yf or -1000, yt or 1000),
    math.random(zf or -1000, zt or 1000)
) end

return vector
