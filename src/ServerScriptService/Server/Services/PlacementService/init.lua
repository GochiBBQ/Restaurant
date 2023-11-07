--[[
    __ __  _   _  _   _  ___  __  __  __  _  
    |  V  || \ / || \ / || _ \/ _]/  \|  \| | 
    | \_/ |`\ V /'`\ V /'| v / [/\ /\ | | ' | 
    |_| |_|  \_/    \_/  |_|_\\__/_||_|_|\__| 

    Author: mvvrgan
    For: Sakura Kitchen 🥢
    https://www.roblox.com/groups/6975354/Sakura-Kitchen#!/about

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local SakuraAutomation = require(Knit.Modules.SakuraAutomation)
local RateLimiter = require(Knit.Modules.RateLimiter)

local RequestRateLimiter = RateLimiter.NewRateLimiter(5)

local PlacementService = Knit.CreateService {
    Name = "PlacementService",
    PlacementObjects = {},
	Client = {},
}

local item = require(script.item)

function PlacementService:PlaceModel(Player: Player, Tool: Tool, CFrame: CFrame)
    Tool.Parent = workspace
    local NewTool = Tool:Clone()
    Tool:Destroy()

    local newItem = item.new(NewTool, CFrame, Player)
    newItem:Place(CFrame)

    table.insert(PlacementService.PlacementObjects, newItem)

    newItem.PlayerPickedUp.Event:Connect(function(Player)
        for i, v in ipairs(PlacementService.PlacementObjects) do
            if v == newItem then
                table.remove(PlacementService.PlacementObjects, i)
            end
        end
    end)
end

function PlacementService.Client:PlaceModel(...)
    PlacementService:PlaceModel(...)
end

return PlacementService