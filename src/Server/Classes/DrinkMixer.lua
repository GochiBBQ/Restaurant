local DrinkMixer = {}
DrinkMixer.__index = DrinkMixer


function DrinkMixer.new()
    local self = setmetatable({}, DrinkMixer)
    return self
end


function DrinkMixer:Destroy()
    
end


return DrinkMixer
