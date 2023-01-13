local vector = require "object.vector"

return function(x_from, y_from, z_from, x_to, y_to, z_to, up)
    local from, to = vector.new(x_from, y_from, z_from), vector.new(x_to, y_to, z_to)
    local n = (from - to):normalize()
    local u = vector.cross(up, n):normalize()
    local v = vector.cross(n, u):normalize()

    return {
        u.x,v.x,n.x,0,
        u.y,v.y,n.y,0,
        u.z,v.z,n.z,0,
        -vector.dot(from, u),
        -vector.dot(from, v),
        -vector.dot(from, n),1
    }
end