--[[

░█▀▀█ ▒█░░░ ▒█▀▀█ ▒█▀▀▀ ░█▀▀█ ▒█▀▀▄ ▒█░░▒█ ▒█▀▀▀ ░█▀▀█ ▒█▄░▒█ ▒█▀▀▀█
▒█▄▄█ ▒█░░░ ▒█▄▄▀ ▒█▀▀▀ ▒█▄▄█ ▒█░▒█ ▒█▄▄▄█ ▒█▀▀▀ ▒█▄▄█ ▒█▒█▒█ ░▀▀▀▄▄
▒█░▒█ ▒█▄▄█ ▒█░▒█ ▒█▄▄▄ ▒█░▒█ ▒█▄▄▀ ░░▒█░░ ▒█░░░ ▒█░▒█ ▒█░░▀█ ▒█▄▄▄█

Author: alreadyfans
For: Fiésta
https://www.roblox.com/groups/32662371/Fi-sta#!/about

]]

-- ————————— 🂡 —————————
-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- ————————— 🂡 —————————
-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)

-- ————————— 🂡 —————————
-- Create Knit Service
local DayCycleService = Knit.CreateService {
    Name = "DayCycleService",
    Client = {},
}

-- ————————— 🂡 —————————
-- Variables
local TimeShift = 50

-- ————————— 🂡 —————————
-- Server Functions
--[[
	Starts the day cycle service.
	Spawns a new task that continuously updates the Lighting's ClockTime every 20 seconds.
	The ClockTime is calculated based on the current minutes after midnight plus an offset of 50 minutes.
	The transition to the new ClockTime is animated using a linear tween over 20 seconds.

	@function KnitStart
	@within DayCycleService
]]
function DayCycleService:KnitStart()
	task.spawn(function()
		while task.wait(20) do
			local minutes = Lighting:GetMinutesAfterMidnight() + TimeShift
			local hours = minutes / 60
	
			local tween = TweenService:Create(Lighting, TweenInfo.new(20, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {ClockTime = hours})
			tween:Play()
		end
	end)
end

-- ————————— 🂡 —————————
 -- Return Service to Knit.
return DayCycleService
