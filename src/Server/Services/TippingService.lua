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

local GamepassList = {}

local AssetType = 34
local Link = 'https://www.roproxy.com/users/inventory/list-json?assetTypeId=%s&cursor=%s&itemsPerPage=100&pageNumber=%s&sortOrder=Desc&userId=%s'

local RankService, NotificationService

-- Server Functions

function TippingService:KnitStart()
    RankService = Knit.GetService("RankService")
    NotificationService = Knit.GetService("NotificationService")

    Players.PlayerAdded:Connect(function(Player)
        Player:SetAttribute("ShowTips", true)
        if RankService:GetRank(Player) >= 4 then
            local Gamepasses = {}
            local PageCursor
    
            local Data = HttpService:GetAsync(Link:format(AssetType, "", 1, Player.UserId))
            local Decoded = HttpService:JSONDecode(Data)
    
            for _,v in ipairs(Decoded["Data"]["Items"]) do
                if v["Creator"]["Id"] == Player.UserId then
                    if v["Product"] ~= nil and v["Product"]["IsForSale"] == true then
                        table.insert(Gamepasses, {
                            v["Item"]["AssetId"],
                            v["Product"]["PriceInRobux"],
                        })
                    end
                end
            end
    
            PageCursor = Decoded["Data"]["nextPageCursor"]
            if PageCursor ~= nil then
                repeat 
                    Data = HttpService:GetAsync(Link:format(AssetType, PageCursor, 1, Player.UserId))
                    Decoded = HttpService:JSONDecode(Data)
    
                    for _,v in ipairs(Decoded["Data"]["Items"]) do
                        if v["Creator"]["Id"] == Player.UserId then
                            if v["Product"] ~= nil and v["Product"]["IsForSale"] == true then
                                table.insert(Gamepasses, {
                                    v["Item"]["AssetId"],
                                    v["Product"]["PriceInRobux"],
                                })
                            end
                        end
                    end
    
                    PageCursor = Decoded["Data"]["nextPageCursor"]
                until PageCursor == nil
            end
            
            --[[
            item["Creator"]["Id"]
            item["Item"]["AssetId"]
            item["Product"]["PriceInRobux"]
            
            Data["Data"]["Items"]
            ]]

            if #Gamepasses > 1 then
                GamepassList[Player.UserId] = Gamepasses
                Player:SetAttribute("TipsEnabled", true)
            else
                Player:SetAttribute("TipsEnabled", false)
            end
        end
    end)

    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(Player, GamepassID, wasPurchased)
        if wasPurchased then
            local ProductInfo = MarketplaceService:GetProductInfo(GamepassID, Enum.InfoType.GamePass)
            if GamepassList[ProductInfo.Creator.Id] ~= nil and #GamepassList[ProductInfo.Creator.Id] > 0 then
                local Price = ProductInfo.PriceInRobux
                local CreatorId = ProductInfo.Creator.Id
                NotificationService:CreateAnnouncement(`<b>{Player.Name}</b> has tipped <b>{ProductInfo.Creator.Name} {Price}</b> robux!`)
                self:Update(TopTippers, Player.UserId, Price)
                self:Update(TopReceivers, CreatorId, Price)
                self:Log(Player, ProductInfo, Price)
            end
        end
    end)

end

function TippingService:Log(Player, ProductInfo, Price)
    warn(Player, ProductInfo.Creator.Name, Price)

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

    warn(response)

    response = HttpService:JSONDecode(response.Body)
    warn(response)
    if not response.success then
        warn(("Error with %d: %s"):format(Player.UserId, response.msg))
    end
end

function TippingService:Update(Datastore: DataStore, UserId: string, Amount: string)
    Datastore:IncrementAsync(UserId, Amount)
end

function TippingService:Get(Player: Player, player: Player)
    local Gamepasses = GamepassList[player.UserId]
    if Gamepasses ~= nil then
        return Gamepasses
    else
        return nil
    end
end

-- Client Functions
function TippingService.Client:GetTips(Player: Player, player: Player)
    return self.Server:Get(Player :: Player, player :: Player)
end

 -- Return Service to Knit.
return TippingService
