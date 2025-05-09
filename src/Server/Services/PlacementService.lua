--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit) --- @module Knit

-- Create Service
local PlacementService = Knit.CreateService {
    Name = "PlacementService",
    Client = {
        RequestPlacement = Knit.CreateSignal(),
    },
}

-- Variables
local PlaceableModels

local TableService
-- Server Functions
function PlacementService:KnitStart()
    TableService = Knit.GetService("TableService")
    PlaceableModels = Knit.Static:WaitForChild("PlaceableModels")

    if not PlaceableModels then
        error("PlacementService: PlaceableModels not found.")
    end
end

function PlacementService:_placeItem(Player: Player, itemName: string, position: Vector3)
    local tableInstance = TableService:GetTableFromPlayer(Player)
    if not tableInstance then return end

    local base = tableInstance:FindFirstChild("Table_Top", true)
    if not base then return end

    local rel = base.CFrame:PointToObjectSpace(position.Position)
    local size = base.Size

    local withinBounds = math.abs(rel.X) <= size.X / 2 and math.abs(rel.Z) <= size.Z / 2
    if not withinBounds then return end

    local item = PlaceableModels:FindFirstChild(itemName)
    if not item then return warn("PlacementService: Item not found.") end

    local placed = item:Clone()
    placed.CFrame = position
    placed.Parent = tableInstance:FindFirstChild("Placed")
end

-- Return Service to Knit
return PlacementService
