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
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")
local TeamService = game:GetService("Teams")

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables
local ProfileTemplate = require(ServerScriptService.Server.Components.ProfileTemplate)
local ProfileModule = require(ServerScriptService.Server.Modules.ProfileService)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Trove = require(ReplicatedStorage.Packages.Trove)
local trove = Trove.new()

local ProfileStore = ProfileModule.GetProfileStore("PlayerData", ProfileTemplate)
local SakuraAutomation = require(Knit.Modules.SakuraAutomation)

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Service
local PlayerService = Knit.CreateService {
    Name = "PlayerService",
	Client = {},
}

Knit.Profiles = {}

-- ————————— ↢ ⭐️ ↣ —————————-
-- Server Functions
function PlayerService:CreateProfile(Player: Player)
	local PlayerProfile = ProfileStore:LoadProfileAsync("Player" .. Player.UserId, nil)
	if Knit.Profiles[Player] then return warn(string.format("🥩 Profile has already been loaded for %s.", Player.Name)) end
	
	if PlayerProfile ~= nil then
		PlayerProfile:AddUserId(Player.UserId)
		PlayerProfile:Reconcile()
	
		PlayerProfile:ListenToRelease(function()
			Knit.Profiles[Player] = nil
			Player:Kick("🥩 The same account was launched onto a different device. Please only connect with one device.")
		end)
	
		if Player:IsDescendantOf(PlayersService) then
			self:CreateData(Player, PlayerProfile.Data)
			Knit.Profiles[Player] = PlayerProfile
			Knit.Signals.PlayerLoaded:Fire(Player)
		else
			PlayerProfile:Release()
		end
	else
		Player:Kick("🥩 Unable to load data onto Roblox Client. Your data has been saved and will load upon rejoining!")
	end
end

function PlayerService:CreateData(Player: Player, Profile: Instance)
	Player:SetAttribute("GochiRank", Player:GetRankInGroup(5874921))
	Player:SetAttribute("WorkerPoints", Profile.WorkerPoints)
	Player:SetAttribute("Petals", Profile.Petals)
	Player:SetAttribute("Movement", false)
	Player:SetAttribute("AFK", false)

	if Player:GetAttribute("SK_Rank") >= 150 then
		Player.Team = TeamService["🌸 Executive"]
	elseif Player:GetAttribute("SK_Rank") >= 90 then
		Player.Team = TeamService["✿ Management"]
	elseif Player:GetAttribute("SK_Rank") >= 40 then
		Player.Team = TeamService["👨‍🍳 Staff Team"]
	end
end

function PlayerService:KnitStart()
	for _, Player in pairs(PlayersService:GetPlayers()) do
		self:CreateProfile(Player)
	end

	PlayersService.PlayerAdded:Connect(function(Player)
		self:CreateProfile(Player)
	end)

	PlayersService.PlayerRemoving:Connect(function(Player)
		local Profile = Knit.Profiles[Player]
		if Profile ~= nil then
			Profile:Release()
		end
	end)
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Service to Knit.
return PlayerService