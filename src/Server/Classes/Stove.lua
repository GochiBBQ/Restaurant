local Stove = {}
Stove.__index = Stove


function Stove.new()
    local self = setmetatable({}, Stove)
    return self
end


function Stove:Destroy()
    
end


return Stove
