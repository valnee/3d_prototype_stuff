return function(a,b,c,d,m,_a)
    local x = a*m[1]+b*m[5]+c*m[9]+d*m[13]
    local y = a*m[2]+b*m[6]+c*m[10]+d*m[14]
    local z = a*m[3]+b*m[7]+c*m[11]+d*m[15]
    local w = a*m[4]+b*m[8]+c*m[12]+d*m[16]
    if _a then
        return ((x*(1/w))*_a)+0.5,
                ((-y*(1/w))*_a)+0.5,
                z,
                w
    end
    return x,y,z,w
end