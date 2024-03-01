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
local UIEffects = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UIEffects"))
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
local UIController

-- ————————— ↢ ⭐️ ↣ —————————-
-- Client Functions
function CameraController:KnitStart()
    TableService = Knit.GetService("GrillService")
    UIController = Knit.GetController("UIController")
    local CookingInfo = UIController.Pages.Parent.CookingInfo

    TableService.Camera:Connect(function(tableGrill: Model)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
        Camera.CameraType = Enum.CameraType.Scriptable

        TweenService:Create(Camera, TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {CFrame = tableGrill.CameraHolder.CFrame}):Play()
        spr.target(CookingInfo, 0.75, 2, { GroupTransparency = 0, Position = UDim2.fromScale(0.5, 0.88)})
        UIEffects:HideUIs()
        
        task.wait(10)
        local PlayerTween = TweenService:Create(Camera, TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {CFrame = Player.Character.Head.CFrame})
        spr.target(CookingInfo, 0.75, 4, { GroupTransparency = 1, Position = UDim2.fromScale(0.5, 0.9)})
        UIEffects:ShowUIs()
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