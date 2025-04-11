--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local DataStoreService = game:GetService("DataStoreService")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise) -- @module Promise
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

-- Variables
local Cooking: Folder = workspace:WaitForChild("Functionality"):WaitForChild("Cooking")

local NavigationService

-- Server Functions
function KitchenService:KnitStart()
    NavigationService = Knit.GetService("NavigationService")
end

function KitchenService:SelectItem(Player: Player, Item: string)
    print("SelectItem", Player, Item)
    Recipes[Item](Player)
end

function KitchenService:_getPlate(Player: Player)
    return Promise.new(function(resolve, reject)
        local Plates = Cooking:WaitForChild("Plates")
        local Plate = Plates:GetChildren()
        local RandomPlate = Plate[math.random(1, #Plate)]

        local result = NavigationService:InitBeam(Player, RandomPlate)

        if result == false then
            reject("Failed to beam item")
            return
        end

        KitchenService.Client.Tasks:Fire(Player, "getPlate", RandomPlate):andThen(function(result)
            if result == true then
                resolve(RandomPlate)
            else
                reject("Failed to get plate")
            end
        end)
    end)
end

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
