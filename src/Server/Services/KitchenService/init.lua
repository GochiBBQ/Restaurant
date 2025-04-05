--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local DataStoreService = game:GetService("DataStoreService")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)

local Classes = Knit.Classes

local DrinkMachines = require(Classes.DrinkMachine)
local DrinkMixers = require(Classes.DrinkMixer)
local Fridges = require(Classes.Fridge)
local Fryers = require(Classes.Fryer)
local PreparationAreas = require(Classes.PreparationArea)
local RiceCookers = require(Classes.RiceCooker)
local Stoves = require(Classes.Stove)
local TrashCans = require(Classes.TrashCan)
local WaffleMakers = require(Classes.WaffleMaker)

local Recipes = require(script.Recipes)

-- Create Knit Service
local KitchenService = Knit.CreateService {
    Name = "KitchenService",
    Client = {
        Tasks = Knit.CreateSignal(),
        Games = Knit.CreateSignal(),

        Fridges = Knit.CreateSignal(),
        Stoves = Knit.CreateSignal(),
        RiceCookers = Knit.CreateSignal(),
        DrinkMachines = Knit.CreateSignal(),
        DrinkMixers = Knit.CreateSignal(),
        Fryers = Knit.CreateSignal(),
        WaffleMakers = Knit.CreateSignal(),
        TrashCans = Knit.CreateSignal(),
        PreparationAreas = Knit.CreateSignal(),

        Complete = Knit.CreateSignal(),
        Alerts = Knit.CreateSignal()
    },
}

-- Client Functions
function KitchenService.Client:UnclaimStove(Player: Player, Stove: Instance)
    -- return Stoves:UnclaimStove(Player, Stove)
end

function KitchenService.Client:SelectReceipe(Player: Player, Stove: Instance, Item: string)
    Recipes[Item](Player, Stove)
end

function KitchenService.Client:SelectFridgeItem(Player: Player, Item: string)
    -- return Fridges:SelectItem(Player, Item)
end

 -- Return Service to Knit.
return KitchenService
