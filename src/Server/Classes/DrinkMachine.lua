local DrinkMachine = {}
DrinkMachine.__index = DrinkMachine


function DrinkMachine.new()
    local self = setmetatable({}, DrinkMachine)
    return self
end


function DrinkMachine:Destroy()
    
end


return DrinkMachine
