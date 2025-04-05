--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Create Knit Service
local CollisionsService = Knit.CreateService {
    Name = "CollisionsService",
    Client = {},
}

-- Server Functions
function CollisionsService:KnitStart()
    -- Register collision groups
    PhysicsService:RegisterCollisionGroup("Players")
    PhysicsService:RegisterCollisionGroup("NPCs")
    
    -- Set collision rules
    PhysicsService:CollisionGroupSetCollidable("Players", "Players", false)
    PhysicsService:CollisionGroupSetCollidable("Players", "NPCs", false)

    -- Function to set collision group for character parts
    local function setCollisionGroupForCharacter(Character)
        for _, object in pairs(Character:GetDescendants()) do
            if object:IsA("BasePart") then
                object.CollisionGroup = "Players"
            end
        end
    end

    -- Connect to PlayerAdded event
    Players.PlayerAdded:Connect(function(Player)
        Player.CharacterAppearanceLoaded:Connect(setCollisionGroupForCharacter)
    end)

    -- Set collision group for existing players
    for _, Player in pairs(Players:GetPlayers()) do
        local Character = Player.Character or Player.CharacterAdded:Wait()
        setCollisionGroupForCharacter(Character)
    end
end

 -- Return Service to Knit.
return CollisionsService
