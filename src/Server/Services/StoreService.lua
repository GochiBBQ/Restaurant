--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players: Players = game:GetService("Players")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit) --- @module Knit
local NametagList: ModuleScript = require(Knit.Data.NametagList) -- @module NametagList
local ParticleList: ModuleScript = require(Knit.Data.ParticleList) -- @module ParticleList
local CrateList: ModuleScript = require(Knit.Data.CrateList) -- @module CrateList

-- Create Service
local StoreService = Knit.CreateService {
    Name = "StoreService",
    Client = {},
}

-- Variables
local InventoryService, CurrencyService, NotificationService

-- Server Functions
function StoreService:KnitStart()
    InventoryService = Knit.GetService("InventoryService")
    CurrencyService = Knit.GetService("CurrencyService") 
    NotificationService = Knit.GetService("NotificationService")
end

function StoreService:_getCrateReward(Player: Player, Crate: string)
    repeat task.wait() until Player:GetAttribute("Loaded")

    local roll = math.random(1, 100)
    local cumulative = 0

    for _, item in ipairs(CrateList[Crate].Rewards) do
        cumulative += item.Chance
        if roll <= cumulative then
            return item
        end
    end

    -- Fallback in case total Chance is under 100
    return CrateList[Crate].Rewards[#CrateList[Crate].Rewards]
end

function StoreService:_purchaseCrate(Player: Player, Crate: string)
    repeat task.wait() until Player:GetAttribute("Loaded")

    local crateInfo = CrateList[Crate]
    local playerBalance = tonumber(CurrencyService:Get(Player))
    local crateCost = crateInfo.Cost

    if playerBalance < crateCost then
        NotificationService:_createNotif(Player, "You do not have enough coins to purchase this crate!")
        return
    end

    -- Roll reward *before* charging
    local reward = self:_getCrateReward(Player, Crate)

    if not reward then
        NotificationService:_createNotif(Player, "Crate opening failed — please try again.")
        return
    end

    -- Deduct coins now that reward is valid
    CurrencyService:Remove(Player, crateCost)

    local isDuplicate = InventoryService:_search(Player, reward.Type, reward.Name)

    if isDuplicate then
        local refundAmount = math.floor(crateInfo.DuplicateRefund * crateCost)
        CurrencyService:Give(Player, refundAmount)
        NotificationService:_createNotif(Player, `You already own this item! You have been refunded {refundAmount} coins.`)
    else
        InventoryService:_update(Player, reward.Type, reward.Name, true)
    end

    -- Generate spinner items (fake spin)
    local spinnerItems = {}
    local possible = crateInfo.Rewards

    for _ = 1, 20 do
        local rand = possible[math.random(1, #possible)]
        table.insert(spinnerItems, rand)
    end

    -- Ensure reward is at the end
    table.insert(spinnerItems, reward)

    return {
        Reward = reward,
        SpinnerList = spinnerItems,
    }
end


-- Client Functions
function StoreService.Client:PurchaseCrate(Player: Player, Crate: string)
    return self.Server:_purchaseCrate(Player, Crate)
end

-- Return Service to Knit
return StoreService
