local camera = {}
local CEIL = math.ceil

function camera.new(position, yaw, pitch, fov, near, far, aspect)
    local self = setmetatable({},{__index = camera})
    self.position    = position
    self.yaw         = yaw     -- x
    self.pitch       = pitch   -- y
    self.fov         = fov  or 75
    self.half_fov    = (fov/2)
    self.near        = near or 0.1
    self.far         = far  or 10
    self.aspect      = aspect or 1.0
    return self
end

return camera   