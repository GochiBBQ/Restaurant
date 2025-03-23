--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove) --- @module Trove

-- Create Knit Service
local ClothingService = Knit.CreateService {
    Name = "ClothingService",
    Client = {},
}

-- Trove instances per player for cleanup
local playerTrove = {}

-- Server Functions
function ClothingService:KnitStart()
    local function onCharacterAdded(player: Player, character: Model)
        local trove = playerTrove[player] or Trove.new()
        playerTrove[player] = trove

        local patch
        local humanoid: Humanoid?
        local wrapLayers: { [WrapLayer]: MeshPart } = {}

        local function onDescendantAdded(desc: Instance)
            if desc:IsA("Humanoid") then
                humanoid = desc
            elseif desc:IsA("WrapLayer") then
                local parent = desc.Parent :: MeshPart
                if parent then
                    wrapLayers[desc] = parent
                end
            end
        end

        local function onDescendantRemoving(desc: Instance)
            if not desc:IsA("Motor6D") then return end

            local thread = HttpService:GenerateGUID()
            patch = thread

            for layer in pairs(wrapLayers) do
                layer.Enabled = false
                layer.Parent = nil
            end

            task.delay(1, function()
                if patch ~= thread then return end
                if humanoid and humanoid:GetState().Name == "Dead" then return end

                local extents = character:GetExtentsSize()
                if extents.Magnitude > 10000 then
                    warn("Extents of", character:GetFullName(), "too large to restore layered clothing!")
                    return
                end

                local canRestore = true
                for layer, mesh in pairs(wrapLayers) do
                    if mesh.Position.Magnitude > 10000 or mesh.AssemblyRootPart == mesh then
                        warn("Position of", mesh:GetFullName(), "too large to restore layered clothing!")
                        canRestore = false
                        break
                    end
                end

                if canRestore then
                    for layer, mesh in pairs(wrapLayers) do
                        layer.Parent = mesh
                        layer.Enabled = true
                    end
                end
            end)
        end

        for _, desc in pairs(character:GetDescendants()) do
            task.spawn(onDescendantAdded, desc)
        end

        trove:Connect(character.DescendantAdded, onDescendantAdded)
        trove:Connect(character.DescendantRemoving, onDescendantRemoving)
    end

    local function onPlayerAdded(player: Player)
        local trove = Trove.new()
        playerTrove[player] = trove

        if player.Character and player.Character:IsDescendantOf(workspace) then
            task.spawn(onCharacterAdded, player, player.Character)
        end

        trove:Connect(player.CharacterAdded, function(char)
            onCharacterAdded(player, char)
        end)

        trove:Connect(player.AncestryChanged, function(_, parent)
            if not parent then
                trove:Destroy()
                playerTrove[player] = nil
            end
        end)
    end

    for _, player in pairs(Players:GetPlayers()) do
        task.spawn(onPlayerAdded, player)
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(function(player)
        if playerTrove[player] then
            playerTrove[player]:Destroy()
            playerTrove[player] = nil
        end
    end)
end

-- Return Service to Knit.
return ClothingService
