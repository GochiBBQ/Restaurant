local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(context, players, coins)
    local CurrencyService = Knit.GetService("CurrencyService")
    for _, player in ipairs(players) do
        CurrencyService:Remove(player, coins)
    end
end