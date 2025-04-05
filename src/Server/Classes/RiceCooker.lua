local RiceCooker = {}
RiceCooker.__index = RiceCooker


function RiceCooker.new()
    local self = setmetatable({}, RiceCooker)
    return self
end


function RiceCooker:Destroy()
    
end


return RiceCooker
