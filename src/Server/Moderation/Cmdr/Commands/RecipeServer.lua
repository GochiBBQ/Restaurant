local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(context, player, item)
    local KitchenService = Knit.GetService("KitchenService")

    if player and item then
        KitchenService:SelectItem(player, item)
    end
end