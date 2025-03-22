--[[

Author: alreadyfans
For: Gochi

]]

-- ————————— 🂡 —————————
-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

-- ————————— 🂡 —————————
-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local ProfileService = require(Knit.Modules.ProfileService)
local template = require(script.template)

-- ————————— 🂡 —————————
-- Create Knit Service
local DataService = Knit.CreateService({
	Name = "DataService",
	Client = {
		UpdateSettings = Knit.CreateSignal(),
	},
	SettingUpdated = Signal.new(),
	DataTransfer = Signal.new(),
	DataKey = "_PlayerData",
})

-- ————————— 🂡 —————————
-- Variables

local ProfileStore = ProfileService.GetProfileStore(DataService.DataKey, template)

Knit.Profiles = {}

local RankService
local GamepassService

local url = "http://138.197.80.59:3001"
local key = `QJvdks3RUn6vklV1G2kQPsUsclZxvDzd`

-- Server Functions
function DataService:LoadProfile(Player: Player)

	local PlayerProfile: table = ProfileStore:LoadProfileAsync(`PlayerData{Player.UserId}_dev3`, "ForceLoad")

	if Knit.Profiles[Player] then
		return
	end

	-- ————————— 🂡 —————————
	-- Check if profile was loaded
	if PlayerProfile ~= nil then
		PlayerProfile:AddUserId(Player.UserId)
		PlayerProfile:Reconcile()

		-- ————————— 🂡 —————————
		-- Listen for changes to profile on other servers
		PlayerProfile:ListenToRelease(function()
			Knit.Profiles[Player] = nil
			Player:Kick("The same account was launched onto a different device. Please only play with one device.")
		end)

		-- ————————— 🂡 —————————
		-- Check if player does exist before assigning profile
		if Player:IsDescendantOf(Players) then
			Knit.Profiles[Player] = PlayerProfile
			Knit.Signals.PlayerLoaded:Fire(Player)
			self:CreateData(Player, PlayerProfile)
			return PlayerProfile
		else
			PlayerProfile:Release()
		end
	else
		Player:Kick("We were unable to retrieve your data. Please rejoin.")
	end
end

function DataService:CreateData(Player: Player, Profile: Instance)
	Player:SetAttribute("Loaded", true)
	Player:SetAttribute("AFK", false)

	-- ————————— 🂡 —————————
	-- Create Leaderboards
	local Leaderstats = Instance.new("Folder")
	Leaderstats.Name = "leaderstats"
	Leaderstats.Parent = Player

	local Rank = Instance.new("StringValue")
	Rank.Value = Player:GetRoleInGroup(5874921)
	Rank.Parent = Leaderstats
	Rank.Name = "Rank"

	-- ————————— 🂡 —————————
	-- Organize Teams
	local Rank = RankService:GetRank(Player)

	if Rank >= 7 then -- Management
		Player:SetAttribute("Staff", true)
	elseif Rank <= 3 then
		Player.Team = Teams["Customer"]
	end
end

function DataService:UpdateSetting(Player: Player, Setting: string, Type: boolean)
	local Profile = Knit.Profiles[Player]

	if Profile then
		local Settings = Profile.Data.Settings['Settings']
		if Settings[Setting] ~= nil then
			Profile.Data.Settings['Settings'][Setting] = Type
			self.Client.UpdateSettings:Fire(Player, Setting, Type)
			self.SettingUpdated:Fire(Player, Setting, Type)

			if Setting == "ShowTips" then
				Player:SetAttribute("ShowTips", Type)
			end
		else
			Profile.Data.Settings['Settings'][Setting] = Type
			self.Client.UpdateSettings:Fire(Player, Setting, Type)
			self.SettingUpdated:Fire(Player, Setting, Type)
		end
	end
end

function DataService:GetSettings(Player)
	while not Player:GetAttribute("Loaded") do
		task.wait()
	end

	local Profile = Knit.Profiles[Player]
	if not Profile then
		return nil
	end

	local Settings = Profile.Data.Settings['Settings']
	if Settings.ShowTips ~= nil then
		Player:SetAttribute("ShowTips", Settings.ShowTips)
	end

	return Settings
end

function DataService:_getJoined(Player: Player)
	
	repeat task.wait() until Player:GetAttribute("Loaded")

	local Profile = Knit.Profiles[Player]
	if not Profile then
		return nil
	end

	if Profile.Data.JoinedBefore ~= nil then
		if Profile.Data.JoinedBefore then
			return true
		else
			return false
		end
	else
		Profile.Data.JoinedBefore = true
		return false
	end
end

function DataService:KnitStart()
	RankService = Knit.GetService("RankService")
	GamepassService = Knit.GetService("GamepassService")

	RankService.UpdateRank:Connect(function(Player)
		Player.leaderstats.Rank.Value = Player:GetRoleInGroup(5874921)
	end)

	for i, Player in next, Players:GetPlayers() do
		self:LoadProfile(Player)

		local _, response = pcall(HttpService.RequestAsync, HttpService, {
			Url = ("%s/booster?id=%d"):format(url, Player.UserId),
			Method = "GET",
			Headers = {
				["Content-Type"] = "application/json",
				["Authorization"] = key,
			},
		})

		response = HttpService:JSONDecode(response.Body)
		if not response.success then
			warn(("Error checking booster status: %s"):format(response.msg))
        else
            Player:SetAttribute("Booster", response.isBooster)
		end
	end

	Players.PlayerAdded:Connect(function(Player)
		if Player.AccountAge < 10 and not game:GetService("RunService"):IsStudio() then
			Player:Kick("Your account is less than 10 days old.")
		end

		self:LoadProfile(Player)

		local _, response = pcall(HttpService.RequestAsync, HttpService, {
			Url = ("%s/booster?id=%d"):format(url, Player.UserId),
			Method = "GET",
			Headers = {
				["Content-Type"] = "application/json",
				["Authorization"] = key,
			},
		})

		response = HttpService:JSONDecode(response.Body)
		if not response.success then
			warn(("Error checking booster status: %s"):format(response.msg))
        else
            Player:SetAttribute("Booster", response.isBooster)
		end
	end)

	Players.PlayerRemoving:Connect(function(Player)
		local Profile = Knit.Profiles[Player]
		if Profile ~= nil then
			Profile:Release()
		end
	end)
end

-- ————————— 🂡 —————————
-- Client Functions
function DataService.Client:Update(Player: Player, Setting: string, Type: boolean)
	self.Server:UpdateSetting(Player, Setting, Type)
end

function DataService.Client:Get(Player: Player)
	return self.Server:GetSettings(Player)
end

function DataService.Client:GetJoined(Player: Player)
	return self.Server:_getJoined(Player :: Player)
end

-- ————————— 🂡 —————————
-- Return Service to Knit.
return DataService