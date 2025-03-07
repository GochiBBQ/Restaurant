local TrashCan = {}
TrashCan.__index = TrashCan


function TrashCan.new()
    local self = setmetatable({}, TrashCan)
    return self
end


function TrashCan:Destroy()
    
end


return TrashCan
