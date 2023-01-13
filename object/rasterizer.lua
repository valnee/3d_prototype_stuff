local rasterizer = {}
local vector = require "object.vector"
local line   = require "object.line"

local function fillBottomFlatTriangle(canvas, v1, v2, v3, color)
    local invslope1 = (v2.x - v1.x) / (v2.y - v1.y)
    local invslope2 = (v3.x - v1.x) / (v3.y - v1.y)

    local x1, x2 = v1.x, v1.x
    for sy=v1.y, v2.y do
        line(canvas, x1, sy, x2, sy, color)
        x1 = x1 + invslope1
        x2 = x2 + invslope2
    end
end

local function fillTopFlatTriangle(canvas, v1, v2, v3, color)
    local invslope1 = (v3.x - v1.x) / (v3.y - v1.y)
    local invslope2 = (v3.x - v2.x) / (v3.y - v2.y)

    local x1, x2 = v3.x, v3.x
    for sy=v1.y, v2.y do
        line(canvas, x1, sy, x2, sy, color)
        x1 = x1 - invslope1
        x2 = x2 - invslope2
    end
end

function rasterizer.scanline(canvas, v1, v2, v3, color)
    local array = {v1, v2, v3}
    table.sort(array, function(a,b) return a.y < b.y end)
    v1 = array[1]
    v2 = array[2]
    v3 = array[3]

    if v2.y == v3.y then
        fillBottomFlatTriangle(canvas, v1,v2,v3, color)
    elseif v1.y == v2.y then
        fillTopFlatTriangle(canvas, v1, v2, v3, color)
    else
        local v4 = vector.new(
            (v1.x + ((v2.y - v1.y) / (v3.y - v1.y)) * (v3.x - v1.x)),
            v2.y,
            0
        )
        fillBottomFlatTriangle(canvas, v1,v2,v4, color)
        fillTopFlatTriangle(canvas, v2, v4, v3, color)
    end
end

function rasterizer.barycentric(canvas, v1,v2,v3, color)
    local minx = math.min(v1.x, math.min(v2.x, v3.x))
    local miny = math.min(v1.y, math.min(v2.y, v3.y))
    local maxx = math.max(v1.x, math.max(v2.x, v3.x))
    local maxy = math.max(v1.y, math.max(v2.y, v3.y))
    
    local vs1 = vector.new(v2.x - v1.x, v2.y - v1.y, 0)
    local vs2 = vector.new(v3.x - v1.x, v3.y - v1.y, 0)
    
    for x=minx, maxx, 1 do
        for y=miny, maxy, 1 do
            local q = vector.new(
                x-v1.x,
                y-v1.y,
                0
            )

            local s = vector.cross(q, vs2) / vector.cross(vs1, vs2)
            local t = vector.cross(vs1, q) / vector.cross(vs1, vs2)
            
            if (s.z >= 0) and (t.z >= 0) and (s.z+t.z <= 1) then
                if canvas:is_in_bounds(x,y) then --[[canvas.canvas[y][x] = color]] end
            end
        end
    end
end

return rasterizer