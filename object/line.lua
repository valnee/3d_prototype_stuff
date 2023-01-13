local CEIL, ABS = math.ceil, math.abs
return function (canv, x1, y1, x2, y2, color)
    if canv:is_in_bounds(x1,y1) and canv:is_in_bounds(x2,y2) then
        if x1 == x2 and y1 == y2 then
            canv.canvas[CEIL(y1-0.5)][CEIL(x1-0.5)] = color
            return
        end
    end
    local function linelow(x1,y1,x2,y2)
        local dx = x2 - x1
        local dy = y2 - y1
        local yi = 1
        if dy < 0 then
            yi = -1
            dy = -dy
        end
        local D =  (2*dy)-dx
        local y = y1
        for x=x1, x2 do
            if canv:is_in_bounds(x,y) then
                canv.canvas[CEIL(y-0.5)][CEIL(x-0.5)] = color
            end
            if D > 0 then
                y = y + yi
                D = D + (2 * (dy-dx))
            else
                D = D + 2*dy
            end
        end
    end

    local function linehight(x1,y1,x2,y2)
        local dx = x2 - x1
        local dy = y2 - y1
        local xi = 1
        if dx < 0 then
            xi = -1
            dx = -dx
        end
        local D =  (2*dx)-dy
        local x = x1
        for y=y1, y2 do
            if canv:is_in_bounds(x,y) then
                canv.canvas[CEIL(y-0.5)][CEIL(x-0.5)] = color
            end
            if D > 0 then
                x = x + xi
                D = D + (2 * (dx-dy))
            else
                D = D + 2*dx
            end
        end
    end

    if ABS(y2 - y1) < ABS(x2 - x1) then
        if x1 > x2 then
            linelow(x2, y2, x1, y1)
        else
            linelow(x1, y1, x2, y2)
        end
    else
        if y1 > y2 then
            linehight(x2, y2, x1, y1)
        else
            linehight(x1, y1, x2, y2)
        end
    end
end