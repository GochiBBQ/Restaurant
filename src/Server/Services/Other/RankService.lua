--[[

█▀▀▄ █▀▀█ █▀▀▄ █▀▀█ █░░█ █▀▀▄ ▀▀█▀▀ ▀▀█ █▀▀█ █▀▀ █░█ 
█░░█ █░░█ █░░█ █░░█ █░░█ █▀▀▄ ░░█░░ ▄▀░ █▄▄█ █░░ █▀▄ 
▀░░▀ ▀▀▀▀ ▀▀▀░ ▀▀▀▀ ░▀▀▀ ▀▀▀░ ░░▀░░ ▀▀▀ ▀░░▀ ▀▀▀ ▀░▀

Author: nodoubtzack
For: Gochí Restaurant 🥩
https://www.roblox.com/groups/5874921/Goch#!/about

]]

-- »»————————————　★　————————————-««
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")

-- »»————————————　★　————————————-««
-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local RateLimiter = require(Knit.Modules.RateManager)

-- »»————————————　★　————————————-««
-- Variables
local RequestRateLimiter = RateLimiter.NewRateLimiter(4)
--TODO: Add ranking service!

-- »»————————————　★　————————————-««
-- Create Knit Service
local RankService = Knit.CreateService {
    Name = "RankService",
	Client = {
	},
}

local PlayerTable = {}

-- »»————————————　★　————————————-««
-- Server Functions
function RankService:KnitStart()
	PlayerService.PlayerAdded:Connect(function(Player)
		PlayerTable[Player.UserId] = { Rank = Player:GetRankInGroup(5874921), Role = Player:GetRoleInGroup(5874921) }

		if self:GetRank(Player) >= 110 then
			Player:SetAttribute("Staff", true)
		end
	end)

	PlayerService.PlayerRemoving:Connect(function(Player)
		PlayerTable[Player.UserId] = nil
	end)
end

function RankService:GetRank(Player: Player)
	if PlayerTable[Player.UserId] then
		return PlayerTable[Player.UserId].Rank
	else
		repeat
			task.wait()
		until PlayerTable[Player.UserId]
		return PlayerTable[Player.UserId].Rank
	end
end

function RankService:GetRole(Player: Player)
	if PlayerTable[Player.UserId] then
		return PlayerTable[Player.UserId].Role
	else
		repeat
			task.wait()
		until PlayerTable[Player.UserId]
		return PlayerTable[Player.UserId].Role
	end
end

function RankService:Promote(Player: Player)
	
end

function RankService:Demote(Player: Player)

end

-- »»————————————　★　————————————-««
-- Client Functions
function RankService.Client:GetRank(Player)
	return self.Server:GetRank(Player)
end

function RankService.Client:GetRole(Player)
	return self.Server:GetRole(Player)
end

-- »»————————————　★　————————————-««
-- Return Service to Knit.
return RankService