--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local Stove = {}
Stove.__index = Stove

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local KitchenService ---@module KitchenService

-- Local Functions
local function LoadAnimation(Character: Instance, Animation: Animation)
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if Humanoid then
		local Animator = Humanoid:FindFirstChildOfClass("Animator")
		if Animator then
			local AnimationTrack = Animator:LoadAnimation(Animation)
			return AnimationTrack
		end
	end
end

-- Server Functions
function Stove:_start(Player: Player, Stove: Instance)
    
end


return Stove
