-- Perspective Projection --
local TAN, RAD = math.tan, math.rad
return function(camera)
    local hfov = RAD(camera.half_fov)
    local f = camera.far
    local n = camera.near
    local a = camera.aspect
    return {
        a/TAN(hfov),0,0,0,
        0,1/(TAN(hfov)),0,0,
        0,0,-f/(f-n),-1,
        0,0,-f*n/(f-n),1
    }
end
