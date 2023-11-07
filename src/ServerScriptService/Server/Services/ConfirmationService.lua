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
local PlayerService = game:GetService("Players")

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)
local trove = Trove.new()

local RateLimiter = require(Knit.Modules.RateLimiter)
local RequestRateLimiter = RateLimiter.NewRateLimiter(4)
local InConfirmation = {}
local Response

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Create Knit Service
local ConfirmationService = Knit.CreateService {
	Name = "ConfirmationService",
	Client = {
		Send = Knit.CreateSignal()	
	},
}

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Server Functions
function ConfirmationService:RequestConfirmation(Player: Player, Message: string)
	if not table.find(InConfirmation, Player) then
		trove:Add(self.Client.Send:Fire(Player, Message))
		table.insert(InConfirmation, Player)

		local Result = self:GetResult(Player)
		return Result
	end
end

function ConfirmationService:GetResult(Player: Player, callback)
	trove:Add(self.Client.Update:Connect(function(Sender: Player, Result: boolean)
		if Player == Sender and Result then
			table.remove(InConfirmation, table.find(InConfirmation, Player))
			Response = true
		else
			table.remove(InConfirmation, table.find(InConfirmation, Player))
			Response = false
		end
	end))

	repeat task.wait() until not table.find(InConfirmation, Player) and Response or not table.find(InConfirmation, Player) and not Response
	return Response
end
-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Return Service to Knit.
return ConfirmationService