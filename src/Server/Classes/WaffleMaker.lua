local WaffleMaker = {}
WaffleMaker.__index = WaffleMaker


function WaffleMaker.new()
    local self = setmetatable({}, WaffleMaker)
    return self
end


function WaffleMaker:Destroy()
    
end


return WaffleMaker
