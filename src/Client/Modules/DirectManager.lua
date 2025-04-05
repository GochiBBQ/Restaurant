--[[

█▀▀▄ █▀▀█ █▀▀▄ █▀▀█ █░░█ █▀▀▄ ▀▀█▀▀ ▀▀█ █▀▀█ █▀▀ █░█ 
█░░█ █░░█ █░░█ █░░█ █░░█ █▀▀▄ ░░█░░ ▄▀░ █▄▄█ █░░ █▀▄ 
▀░░▀ ▀▀▀▀ ▀▀▀░ ▀▀▀▀ ░▀▀▀ ▀▀▀░ ░░▀░░ ▀▀▀ ▀░░▀ ▀▀▀ ▀░▀

Author: nodoubtzack
For: Sakura Kitchen 🥢
https://www.roblox.com/groups/6975354/Sakura-Kitchen#!/about

]]

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Variables
local ArrowBeam = ReplicatedStorage:WaitForChild("Static"):FindFirstChild("ArrowDirect")
local Player = Players.LocalPlayer
local module = {}

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Functions
local function PathToPart(Beam, Attachment0, Part)
    local Attachment1 = Part:FindFirstChildOfClass("Attachment")
    if Attachment1 then
        Beam.Attachment0 = Attachment0
        Beam.Attachment1 = Attachment1
    else
        warn(string.format("🥢An attachment was not inserted into %s.", Part:GetFullName()))
    end
end

function module:Direct(ToPart)
    if ToPart == nil then
        if Player.Character.HumanoidRootPart:FindFirstChild("ArrowDirect") then
            Player.Character.HumanoidRootPart:FindFirstChild("ArrowDirect"):Destroy()
        end
    else
        if Player.Character and ToPart:IsA("BasePart") or ToPart:IsA("MeshPart") then
            if Player.Character.HumanoidRootPart:FindFirstChild("ArrowDirect") then
                Player.Character.HumanoidRootPart:FindFirstChild("ArrowDirect"):Destroy()
            end

            local HRP = Player.Character:FindFirstChild("HumanoidRootPart")
            local Attachment0 = HRP:FindFirstChild("RootRigAttachment")
            local Beam = ArrowBeam:Clone()

            PathToPart(Beam, Attachment0, ToPart)
            Beam.Parent = Player.Character.HumanoidRootPart
        end
    end
end

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Return module.
return module