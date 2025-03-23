--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Variables
local Player = Players.LocalPlayer

local PlayerStorage = workspace:WaitForChild("PlayerStorage")
local Beam: Beam = ReplicatedStorage:WaitForChild("Static"):WaitForChild("Beam")

local NavigationService

-- Create Knit Controller
local NavigationController = Knit.CreateController {
    Name = "NavigationController",
}

-- Trove for managing the single active beam
NavigationController._beamTrove = Trove.new()

-- Client Functions
function NavigationController:KnitStart()
    NavigationService = Knit.GetService("NavigationService")

    NavigationService.Init:Connect(function(model: Instance)
        self:InitBeam(model)
    end)
end

function NavigationController:InitBeam(model: Instance)
    assert(model and model:IsA("Model"), "Invalid model provided.")
    assert(Beam and PlayerStorage, "Missing Beam or PlayerStorage references.")

    -- Clean up any existing beam first
    self._beamTrove:Clean()

    local beamsFolder = PlayerStorage:WaitForChild("Beams"):WaitForChild(Player.Name)
    if not beamsFolder then
        beamsFolder = Instance.new("Folder")
        beamsFolder.Name = "Beams"
        beamsFolder.Parent = PlayerStorage:WaitForChild(Player.Name)
    end

    local beamClone = Beam:Clone()
    local character = Player.Character or Player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Create or get player attachment
    local playerAttachment = humanoidRootPart:FindFirstChild("beamAttachment")
    if not playerAttachment then
        playerAttachment = Instance.new("Attachment")
        playerAttachment.Name = "beamAttachment"
        playerAttachment.Parent = humanoidRootPart
    end

    -- Create or get model attachment
    local modelAttachment = model:FindFirstChild("beamAttachment")
    if not modelAttachment then
        local primaryPart = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
        assert(primaryPart, "Model missing a suitable BasePart.")
        modelAttachment = Instance.new("Attachment")
        modelAttachment.Name = "beamAttachment"
        modelAttachment.Parent = primaryPart
    end

    beamClone.Name = `{model.Name}_Beam`
    beamClone.Attachment0 = playerAttachment
    beamClone.Attachment1 = modelAttachment
    beamClone.Enabled = true
    beamClone.Parent = beamsFolder

    -- Store the beam + any connections in the trove
    self._beamTrove:Add(beamClone)

    local primaryPart = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
    local connection = game:GetService("RunService").Heartbeat:Connect(function()
        if primaryPart then
            local distance = (humanoidRootPart.Position - primaryPart.Position).Magnitude
            if distance <= 7 then
                self._beamTrove:Clean()
            end
        end
    end)

    self._beamTrove:Connect(connection)
end

return NavigationController
