local PreparationArea = {}
PreparationArea.__index = PreparationArea


function PreparationArea.new()
    local self = setmetatable({}, PreparationArea)
    return self
end


function PreparationArea:Destroy()
    
end


return PreparationArea
