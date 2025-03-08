local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(context, players, xp)
    local ExperienceService = Knit.GetService("ExperienceService")
    for _, player in ipairs(players) do
        ExperienceService:Set(player, xp)
    end
end