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
local PlayerService = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables
local spr = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("spr"))
local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = PlayerService.LocalPlayer

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Controller
local CameraController = Knit.CreateController {
    Name = "CameraController",
}

local Camera = workspace.CurrentCamera
local TableService

-- ————————— ↢ ⭐️ ↣ —————————-
-- Client Functions
function CameraController:KnitStart()
    TableService = Knit.GetService("GrillService")

    TableService.Camera:Connect(function(tableGrill: Model)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
        Camera.CameraType = Enum.CameraType.Scriptable

        TweenService:Create(Camera, TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {CFrame = tableGrill.CameraHolder.CFrame}):Play()
        task.wait(10)
        local PlayerTween = TweenService:Create(Camera, TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {CFrame = Player.Character.Head.CFrame})
        PlayerTween:Play()

        PlayerTween.Completed:Connect(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
            Camera.CameraType = Enum.CameraType.Custom
        end)
    end)
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Controller to Knit.
return CameraController