local Fryer = {}
Fryer.__index = Fryer


function Fryer.new()
    local self = setmetatable({}, Fryer)
    return self
end


function Fryer:Destroy()
    
end


return Fryer
