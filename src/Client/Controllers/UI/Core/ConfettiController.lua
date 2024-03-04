--[[
    
    █▀▀▄ █▀▀█ █▀▀▄ █▀▀█ █░░█ █▀▀▄ ▀▀█▀▀ ▀▀█ █▀▀█ █▀▀ █░█ 
    █░░█ █░░█ █░░█ █░░█ █░░█ █▀▀▄ ░░█░░ ▄▀░ █▄▄█ █░░ █▀▄ 
    ▀░░▀ ▀▀▀▀ ▀▀▀░ ▀▀▀▀ ░▀▀▀ ▀▀▀░ ░░▀░░ ▀▀▀ ▀░░▀ ▀▀▀ ▀░▀

    Author: nodoubtzack
    For: Gochi Restaurant 🥩
    https://www.roblox.com/games/14203094444/Goch-Restaurant

]]

-- ————————— 🂡 —————————
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")

-- ————————— 🂡 —————————
-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local ConfettiManager = require(Knit.Modules.ConfettiManager)

-- ————————— 🂡 —————————
-- Variables
local ConfettiActive = false

-- ————————— 🂡 —————————
-- Create Knit Controller
local ConfettiController = Knit.CreateController{ 
    Name = "ConfettiController"
}

-- ————————— 🂡 —————————
-- Client Functions
function ConfettiController:CreateConfetti()
    SoundService.Confetti.ConfettiSound:Play()
    task.spawn(function()
        ConfettiActive = true;
		task.wait(0.5)
		ConfettiActive = false;
    end)
end

function ConfettiController:KnitStart()
    ConfettiManager.setGravity(Vector2.new(0,1))
    local Confetti = {}
    local AmountOfConfetti = 70

    for i = 1, AmountOfConfetti do
        local Particle = ConfettiManager.createParticle(Vector2.new(0.5,1), Vector2.new(math.random(90)-45, math.random(70,100)),  PlayerService.LocalPlayer.PlayerGui:WaitForChild("ConfettiCannon"):WaitForChild("ConfettiFrame"), {Color3.fromRGB(196, 255, 171), Color3.fromRGB(85, 170, 255), Color3.fromRGB(255, 255, 127), Color3.fromRGB(255, 130, 130), Color3.fromRGB(170, 170, 255)})
        table.insert(Confetti, Particle);
    end
    
    RunService.RenderStepped:Connect(function()
        for _, Val in pairs(Confetti) do
            Val.Enabled = ConfettiActive
            Val:Update()
        end
    end)
end

-- ————————— 🂡 —————————
-- Return Controller to Knit
return ConfettiController