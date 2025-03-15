--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local TipUtil = require(ReplicatedStorage.Util.TipUtil) -- @module TipUtil

-- Create Knit Service
local TippingService = Knit.CreateService {
    Name = "TippingService",
    Client = {
        Notification = Knit.CreateSignal()
    },
}

-- Variables

local url = "http://138.197.80.59:3001"
local key = `QJvdks3RUn6vklV1G2kQPsUsclZxvDzd`

local TopTippers = DataStoreService:GetOrderedDataStore("TopTippers")
local TopReceivers = DataStoreService:GetOrderedDataStore("TopReceivers")

local PassesToPlayers: { [number]: Player } = {}

local RankService, NotificationService

-- Server Functions

function TippingService:HandlePlayer(Player: Player)
    local Rank = RankService:GetRank(Player)

    if Rank < 4 then return end

    local Profile = Knit.Profiles[Player]

    if Profile then
        if #Profile.Data.Gamepasses < 1 then
            local gamepasses = TipUtil:GetUserGamepasses(Player.UserId)

            Profile.Data.Gamepasses = gamepasses

            return
        end

        for _, passId in Profile.Data.Gamepasses do
            PassesToPlayers[passId] = Player
        end

        if #Profile.Data.Gamepasses > 0 then
            Player:SetAttribute("TipsEnabled", true)
        else
            Player:SetAttribute("TipsEnabled", false)
        end
    end
end

function TippingService:KnitStart()
    RankService = Knit.GetService("RankService")
    NotificationService = Knit.GetService("NotificationService")

    Players.PlayerAdded:Connect(function(Player)
        self:HandlePlayer(Player)
    end)

    for _, Player in Players:GetPlayers() do
        self:HandlePlayer(Player)
    end

    Players.PlayerRemoving:Connect(function(Player)
        for passId, passPlayer in pairs(PassesToPlayers) do
            if passPlayer == Player then
                PassesToPlayers[passId] = nil
            end
        end
    end)

    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
        if not wasPurchased then return end

        if not PassesToPlayers[gamePassId] then return end

        local price = MarketplaceService:GetProductInfo(gamePassId, Enum.InfoType.GamePass).PriceInRobux

        NotificationService:CreateAnnouncement(`<b>{player.Name}</b> has tipped <b>{PassesToPlayers[gamePassId].Name} {price}</b> robux!`)
        self:Update(TopTippers, player.UserId, price)
        self:Update(TopReceivers, PassesToPlayers[gamePassId].UserId, price)
        self:Log(player, gamePassId, price)
    end)

end

function TippingService:Log(Player: Player, GamepassID: number, Price: number)
    local ProductInfo = MarketplaceService:GetProductInfo(GamepassID, Enum.InfoType.GamePass)

    local info = {
        ["tipper"] = Player.Name,
        ["receiver"] = ProductInfo.Creator.Name,
        ["amount"] = Price,
    }

    local _, response = pcall(HttpService.RequestAsync, HttpService, {
        Url = ("%s/tip"):format(url),
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = key,  
        },
        Body = HttpService:JSONEncode(info)

    })

    response = HttpService:JSONDecode(response.Body)
    if not response.success then
        warn(("Error with %d: %s"):format(Player.UserId, response.msg))
    end
end

function TippingService:Update(Datastore: DataStore, UserId: string, Amount: string)
    Datastore:IncrementAsync(UserId, Amount)
end

function TippingService:Get(player: Player)
    local playerPasses = {}
    for passId, passPlayer in pairs(PassesToPlayers) do
        if passPlayer == player then
            table.insert(playerPasses, passId)
        end
    end
    return playerPasses
end

-- Client Functions
function TippingService.Client:GetTips(Initiator: Player, player: Player)
    return self.Server:Get(player :: Player)
end

 -- Return Service to Knit.
return TippingService
