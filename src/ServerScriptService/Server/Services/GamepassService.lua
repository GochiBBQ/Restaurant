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
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)
local GamepassData = require(Knit.Data.GamepassData)

local RateLimiter = require(Knit.Modules.RateLimiter)
local RequestRateLimiter = RateLimiter.NewRateLimiter(4)

local CheckingPasses = {}

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Create Knit Service
local GamepassService = Knit.CreateService {
    Name = "GamepassService",
	Client = {
		Update = Knit.CreateSignal()	
	},
}

Knit.Gamepasses = {} -- [Player][GamepassId] == Boolean Value

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Server Functions
function GamepassService:GetGamepasses(Player: Player)
	CheckingPasses[Player] = true
	Knit.Gamepasses[Player] = {}

	task.spawn(function()
		repeat task.wait() until Player:GetAttribute("SK_Rank")

		for Id, Data in pairs(GamepassData) do
			local Success, Response = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, Player.UserId, Id)
			Knit.Gamepasses[Player][Id] = Response

			if (Success and Response) or Player:GetAttribute("SK_Rank") >= 180 then
				Knit.Gamepasses[Player][Id] = true

				if Data["Owns"] then
					task.spawn(function() Data["Owns"](Player) end)
				elseif not Success then
					warn("⚠️ GamepassService | Error while checking for gamepass ownership for " .. Player.Name .. ": " .. Response)
				end
			end

			MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(Player: Player, Id: number, wasPurchased: boolean)
				if not Knit.Gamepasses[Player][Id] and wasPurchased then
					Knit.Gamepasses[Player][Id] = true

					if GamepassData[Id]["Owns"] then
						task.spawn(function() GamepassData[Id]["Owns"](Player) end)
					end

					self.Client.Update:Fire(Player, Knit.Gamepasses[Player])
				end
			end)
		end

		CheckingPasses[Player] = nil
		self.Client.Update:Fire(Player, Knit.Gamepasses[Player])
	end)
end

function GamepassService:KnitStart()
	for _, Player in ipairs(PlayerService:GetPlayers()) do
		self:GetGamepasses(Player)
	end

	PlayerService.PlayerAdded:Connect(function(Player)
		self:GetGamepasses(Player)
	end)

	PlayerService.PlayerRemoving:Connect(function(Player)
        task.delay(60, function()
            if not PlayerService:FindFirstChild(Player.Name) then
                Knit.Gamepasses[Player] = nil
            end
        end)
    end)
end

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Client Functions
function GamepassService.Client:GetOwnedPasses(Player)
	repeat task.wait() until not CheckingPasses[Player]
    return Knit.Gamepasses[Player]
end

function GamepassService.Client:GetAvailablePasses(Player)
	return GamepassData
end

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Return Service to Knit.
return GamepassService