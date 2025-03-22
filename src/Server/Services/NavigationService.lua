--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService("ServerStorage")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Create Knit Service
local NavigationService = Knit.CreateService {
    Name = "NavigationService",
    Client = {
        Init = Knit.CreateSignal(),
    },
}

-- Variables
local PlayerStorage = workspace:WaitForChild("PlayerStorage")

-- Server Functions
function NavigationService:KnitStart()
    Players.PlayerAdded:Connect(function(Player)
        repeat task.wait() until Player:GetAttribute("Loaded")

        local folder = Instance.new("Folder", PlayerStorage.Beams)
        folder.Name = Player.Name
    end)
end

function NavigationService:InitBeam(Player: Player, Model: Instance)
    local result = self.Client.Init:Fire(Player, Model)

    if result == nil then
        return true
    end

    return false
end

-- Client Functions
function NavigationService.Client:Beam(Player: Player, Model: Instance)
    return self.Server:InitBeam(Player, Model)
end

 -- Return Service to Knit.
return NavigationService
