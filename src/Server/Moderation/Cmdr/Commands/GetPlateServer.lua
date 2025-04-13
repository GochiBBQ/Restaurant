local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(context, player)
    local KitchenService = Knit.GetService("KitchenService")

    if player then
        KitchenService:_getPlate(player)
    end
end