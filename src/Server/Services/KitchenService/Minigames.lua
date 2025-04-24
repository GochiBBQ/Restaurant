--[[
Author: alreadyfans
For: Gochi
]]

-- Lua Class
local Minigames = {}
Minigames.__index = Minigames

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit) ---@module Knit
local Signal = require(ReplicatedStorage.Packages.Signal) ---@module Signal
local Promise = require(ReplicatedStorage.Packages.Promise) ---@module Promise

-- Variables
local KitchenService

local ongoingMinigames = {}
local minigames = {
	"Math",
	-- You can add more minigames like "PuzzleSelection"
}

Knit.OnStart():andThen(function()
	KitchenService = Knit.GetService("KitchenService")
end)

-- Start a random minigame for a player
function Minigames:startRandomMinigame(Player: Player)
	Promise.new(function(resolve, reject)
		local randomMinigame = minigames[math.random(1, #minigames)]

		local minigameFunction = Minigames[randomMinigame:lower() .. "Minigame"]
		if not minigameFunction then
			reject("Minigame function not found for: " .. tostring(randomMinigame))
			return KitchenService.Client.MinigameComplete:Fire(Player, false, "Minigame function not found")
		end

		local completedSignal = Signal.new()
		ongoingMinigames[Player.UserId] = {
			minigame = randomMinigame,
			Completed = completedSignal,
			isActive = true
		}

		KitchenService.Client.Games:Fire(Player, randomMinigame)
        minigameFunction(Player)

		local connection
		connection = completedSignal:Connect(function()
			print("Minigame completed: " .. randomMinigame)
			completedSignal:Destroy()
			connection:Disconnect()
			ongoingMinigames[Player.UserId] = nil
			resolve(true)
			return KitchenService.Client.MinigameComplete:Fire(Player, true)
		end)
	end)
end



-- Placeholder minigame logic
Minigames.mathMinigame = function(Player: Player)
	-- Server-side logic here, or just leave empty if all happens on the client
end

Minigames.puzzleSelectionMinigame = function(Player: Player)
	-- Optional future minigame
end

-- Called when the player completes their minigame
function Minigames:Complete(Player: Player)
	local data = ongoingMinigames[Player.UserId]
	if not data or not data.isActive then
		return
	end

	data.isActive = false
	data.Completed:Fire()
end

return Minigames
