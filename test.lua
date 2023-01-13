local rasterizer = require "object.rasterizer"
local camera     = require "object.camera"
local vector     = require "object.vector"
local line       = require "object.line"
local pxl        = require "pxl"

local matmul             = require "matrices.matmul"
local projection_matrice = require "matrices.projection"
local translate_matrice  = require "matrices.translate"
local lookat_matrice     = require "matrices.lookat"

local canvas = pxl.new(term, colors.black)
local cam = camera.new(vector.new(0,0,0), 0, 0, 75, -0.5, 1000, canvas.height/canvas.width)
local cam_speed = 2

local position = vector.new(0,0,100)
local scale = 10

local vertices = {
    -- front --
    vector.new(1,1,-1),    -- 1
    vector.new(1,-1,-1),   -- 2
    vector.new(-1,-1,-1),  -- 3
    vector.new(-1,1,-1),   -- 4

    -- back --
    vector.new(1,1,1),    -- 5
    vector.new(1,-1,1),   -- 6
    vector.new(-1,-1,1),  -- 7
    vector.new(-1,1,1),   -- 8
}

local triangles = {
    -- front --
    {1,2,3, colors.white},
    {3,4,1, colors.white},

    -- back --
    {5,6,7, colors.white},
    {8,7,5, colors.white},

    -- left --
    {1,2,5, colors.white},
    {5,6,2, colors.white},

    -- right --
    --{4,6,1, colors.orange},
    {7,8,4, colors.white},
    {3,4,7, colors.white},

    -- top --
    {2,3,6, colors.white},
    {3,6,7, colors.white},

    -- bottom --
    {1,4,5, colors.white},
    {5,8,4, colors.white}
}

local from = cam.position
local to = vector.new(
    -math.sin(math.rad(cam.yaw))*math.cos(math.rad(cam.pitch)),   -- x
    math.sin(math.rad(cam.pitch)),                -- y
    -math.cos(math.rad(cam.yaw))*math.cos(math.rad(cam.pitch))    -- z
)

--[[
1. scale
2. rotate
3. transform
4. camera transform
5. camera rotate
6. perspective 
]]

local function get_move_vector(yaw)
    return vector.new(
        -math.sin(yaw),
        0,
        -math.cos(yaw)
    ):normalize()
end

local rotation_angle = 1
local rotation_vector = vector.new(0, rotation_angle, 0 )
local function run()
    while true do
        -- Clone Vertices --
        local cv = {}
        for i=1, #vertices do cv[i] = vertices[i]:clone() end

        -- Projection Matrice --
        local proj_matrice = projection_matrice(cam)

        -- LookAt Matrice --
        from = cam.position
        to = vector.new(
            -math.sin(math.rad(cam.yaw))*math.cos(math.rad(cam.pitch)),   -- x
            math.sin(math.rad(cam.pitch)),                -- y
            -math.cos(math.rad(cam.yaw))*math.cos(math.rad(cam.pitch))    -- z
        )

        -- Scale --
        for i=1, #cv do 
            cv[i]:scale(vector.ones()*scale)
        end

        -- Rotate --
        for i=1, #cv do cv[i]:rotate(rotation_vector) end
        rotation_vector = rotation_vector + rotation_vector:normalize()

        -- Transform --
        for i=1, #cv do 
            cv[i]:translate(position)
        end

        -- Camera Transform --
        for i=1, #cv do cv[i]:lookat(from, from+to, vector.up()) end
        
        -- Camera Rotate --
        --for i=1, #cv do cv[i]:lookat(from, to, vector.up()) end

        -- Perspective & Render --
        for i=1, #triangles do
            local p1, p2, p3, color = cv[triangles[i][1]], cv[triangles[i][2]], cv[triangles[i][3]], triangles[i][4]
            local p1x, p1y, p1z, p1w = matmul(p1.x, p1.y, p1.z, p1.w, proj_matrice, cam.aspect)
            local p2x, p2y, p2z, p2w = matmul(p2.x, p2.y, p2.z, p2.w, proj_matrice, cam.aspect)
            local p3x, p3y, p3z, p3w = matmul(p3.x, p3.y, p3.z, p3.w, proj_matrice, cam.aspect)
            p1x, p1y = p1x*canvas.width, p1y*canvas.height
            p2x, p2y = p2x*canvas.width, p2y*canvas.height
            p3x, p3y = p3x*canvas.width, p3y*canvas.height
            
            local _p1 = vector.new(p1x, p1y, p1z)
            local _p2 = vector.new(p2x, p2y, p2z)
            local _p3 = vector.new(p3x, p3y, p3z)
            -- Rasterizer --
            -- don't made it yet -- rasterizer.barycentric(canvas, _p1, _p2, _p3, color)
            -- Lines edit those lines or do any stuff idk --
            line(canvas, p1x,p1y, p2x,p2y, colors.red)
            line(canvas, p2x,p2y, p3x,p3y, colors.red)
            line(canvas, p3x,p3y, p1x,p1y, colors.red)
        end 

        -- Debug render --
        local debug_string = [[]]
        debug_string = debug_string .. "[Vertices]                             \n"
        for i=1, #cv do
            local str = "[" .. tostring(i) .. "] x:" .. tostring(cv[i].x) .. " y:" .. tostring(cv[i].y) .. " z:" .. tostring(cv[i].z) .. "\n"
            debug_string = debug_string .. str
        end
        debug_string = debug_string .. "[Info]                                 \n[Object Position] x:" .. tostring(position.x) .. " y:" .. tostring(position.y) .. " z:" .. tostring(position.z) .. "\n" 
        debug_string = debug_string .. "[Camera Position X/Y/Z] " .. tostring(cam.position.x) .. "/" .. tostring(cam.position.y) .. "/" .. tostring(cam.position.z) .. "\n" 
        debug_string = debug_string .. "[Camera Far/Near/Aspect] " .. tostring(cam.far) .. "/" .. tostring(cam.near) .. "/" .. tostring(cam.aspect) .. "\n" 
        debug_string = debug_string .. "[Camera Yaw/Pitch] " .. tostring(cam.yaw) .. "/" .. tostring(cam.pitch) .. "\n"
        debug_string = debug_string .. "[To X/Y/Z] " .. tostring(to.x) .. "/" .. tostring(to.y) .. "/" .. tostring(to.z)

        canvas:write_text(1,1, debug_string, true, colors.white, colors.black)

        -- Reset Buffers --
        canvas:render()
        pxl.restore(canvas, colors.black)
        pxl.restore_chars(canvas, "", colors.black, colors.white)
        sleep()
    end
end
local no_height_vec = vector.new(1,0,1)
local function userinput()
    while true do
        local eventData = {os.pullEvent()}
        local event = eventData[1]

        if event == "key" then
            local key = eventData[2]
            if key == 16 then error("Terminated") end
            local m = get_move_vector(math.rad(cam.yaw))
            if key == keys.w then cam.position = cam.position - m end -- W
            if key == keys.a then cam.position = cam.position + get_move_vector(math.rad(cam.yaw-90))*no_height_vec end -- A
            if key == keys.s then cam.position = cam.position + m end -- S
            if key == keys.d then cam.position = cam.position + get_move_vector(math.rad(cam.yaw+90))*no_height_vec  end -- D
            if key == 200 then if cam.pitch < 90 then cam.pitch = cam.pitch + 0.5 end end -- arrow up
            if key == 208 then if cam.pitch > -90 then cam.pitch = cam.pitch - 0.5 end end -- arrow down
            if key == 203 then cam.yaw = cam.yaw + 0.5 end -- arrow left
            if key == 205 then cam.yaw = cam.yaw - 0.5 end -- arrow right

            --print(key, string.char(key))
        end
    end
end

parallel.waitForAny(run, userinput)
