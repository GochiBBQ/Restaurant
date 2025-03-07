local Fridge = {}
Fridge.__index = Fridge


function Fridge.new()
    local self = setmetatable({}, Fridge)
    return self
end


function Fridge:Destroy()
    
end


return Fridge
