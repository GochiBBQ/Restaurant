--[[

█▀▀▄ █▀▀█ █▀▀▄ █▀▀█ █░░█ █▀▀▄ ▀▀█▀▀ ▀▀█ █▀▀█ █▀▀ █░█ 
█░░█ █░░█ █░░█ █░░█ █░░█ █▀▀▄ ░░█░░ ▄▀░ █▄▄█ █░░ █▀▄ 
▀░░▀ ▀▀▀▀ ▀▀▀░ ▀▀▀▀ ░▀▀▀ ▀▀▀░ ░░▀░░ ▀▀▀ ▀░░▀ ▀▀▀ ▀░▀

Author: nodoubtzack
For: Gochí Restaurant 🥩
https://www.roblox.com/groups/5874921/Goch#!/about

]]

-- ————————— ↢ ⭐️ ↣ —————————
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)

local TableGrills = {}
TableGrills.__index = TableGrills

-- ————————— ↢ ⭐️ ↣ —————————-
-- Server Functions
function TableGrills.new(tableGrill: Model)
    local self = setmetatable({}, TableGrills)

    self.Server = nil
    self.Customers = {}
    self.Grill = tableGrill

    self:Initialize(tableGrill)
    return self
end

function TableGrills:Initialize(tableGrill: Model)
    tableGrill.PromptHolder.ProximityPrompt.Triggered:Connect(function(Player)
        self:DisplayItem(tableGrill, "Raw Pork Belly", true)
    end)
end

function TableGrills:DisplayItem(Grill: Model, Item: string, Value: boolean)
    if Value and Grill.Food:FindFirstChild(Item) then
        Grill.Primary.PrimaryModel.PrimaryModel.TableGrill.GrillingMeats:FindFirstChild(Item).Transparency = 0
    else
        Grill.Primary.PrimaryModel.PrimaryModel.TableGrill.GrillingMeats:FindFirstChild(Item).Transparency = 1
	end
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Module to Knit.
return TableGrills