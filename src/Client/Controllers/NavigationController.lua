--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Zone = require(ReplicatedStorage.Modules.Zone) --- @module Zone

-- Variables
local Player = Players.LocalPlayer

local PlayerStorage = workspace:WaitForChild("PlayerStorage")
local Beam: Beam = ReplicatedStorage:WaitForChild("Static"):WaitForChild("Beam")

local NavigationService

-- Create Knit Controller
local NavigationController = Knit.CreateController {
    Name = "NavigationController",
}

-- Client Functions
function NavigationController:KnitStart()
    NavigationService = Knit.GetService("NavigationService")

    NavigationService.Init:Connect(function(model: Instance)
        self:InitBeam(model)
    end)
end

function NavigationController:InitBeam(model: Instance)
    -- Ensure Beam and PlayerStorage are valid
    assert(Beam, "Beam is not defined")
    assert(PlayerStorage, "PlayerStorage is not defined")

    local beamClone = Beam:Clone()

    -- Get the player's character
    local character = Player.Character or Player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Ensure the player's attachment exists
    local playerAttachment = humanoidRootPart:FindFirstChild("beamAttachment")
    if not playerAttachment then
        playerAttachment = Instance.new("Attachment")
        playerAttachment.Name = "beamAttachment"
        playerAttachment.Parent = humanoidRootPart
    end

    -- Ensure the model's attachment exists
    local modelAttachment = model:FindFirstChild("beamAttachment")
    if not modelAttachment then
        modelAttachment = Instance.new("Attachment")
        modelAttachment.Name = "beamAttachment"
        local primaryPart = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
        assert(primaryPart, "Model does not have a PrimaryPart, HumanoidRootPart, or any BasePart")
        modelAttachment.Parent = primaryPart
    end

    -- Ensure the Beams folder exists in PlayerStorage
    local beamsFolder = PlayerStorage:FindFirstChild("Beams")
    if not beamsFolder then
        beamsFolder = Instance.new("Folder")
        beamsFolder.Name = "Beams"
        beamsFolder.Parent = PlayerStorage
    end

    -- Set up the beam
    beamClone.Parent = beamsFolder
    beamClone.Attachment0 = playerAttachment
    beamClone.Attachment1 = modelAttachment
    beamClone.Enabled = true

    local zone = Zone.new(model)

    zone.playerEntered:Connect(function(player: Player)
        if player == Players.LocalPlayer then
            beamClone:Destroy()
            zone:Destroy()
        end
    end)
end

 -- Return Controller to Knit.
return NavigationController
