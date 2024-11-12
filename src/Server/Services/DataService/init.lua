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

-- ————————— 🂡 —————————
-- Server Functions
--[[
	Loads the player's profile data from the ProfileStore and assigns it to the player.
	If the profile is already loaded, it returns immediately. Otherwise, it loads the profile,
	reconciles it, and sets up listeners for profile changes on other servers. If the player
	is still in the game, it assigns the profile to the player and fires the PlayerLoaded signal.
	If the profile cannot be loaded, the player is kicked from the game.

	@function LoadProfile
	@param Player Player -- The player whose profile is being loaded.
	@within DataService
]]
function DataService:LoadProfile(Player: Player)
	-- Don't use `PlayerData{Player.UserId}`, existing data
	local PlayerProfile: table = ProfileStore:LoadProfileAsync(`PlayerData{Player.UserId}_dev1`, "ForceLoad")

	if Knit.Profiles[Player] then
		return
	end -- A profile exists already, return

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

--[[
	Creates data for a player, including setting initial attributes, creating leaderboards, and organizing teams based on the player's rank.

	@function CreateData
	@param Player Player -- The player for whom the data is being created.
	@param Profile Instance -- The profile instance associated with the player.
	@within DataService
]]
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
		Player.Team = Teams["Management"]
		Player:SetAttribute("Staff", true)
	elseif Rank <= 3 then
		Player.Team = Teams["Customer"]
	end
end

--[[
	Updates a player's setting in their profile.
	Checks if the player has the required game pass for the setting, updates the setting in the player's profile,
	and fires relevant events to notify clients and other services. If the setting is "DisableTips", it also updates
	the player's "ShowTips" attribute accordingly.

	@function UpdateSetting
	@param Player Player -- The player whose setting is being updated.
	@param Setting string -- The name of the setting to update.
	@param Type boolean -- The new value for the setting.
	@within DataService
]]
function DataService:UpdateSetting(Player: Player, Setting: string, Type: boolean)
	local Profile = Knit.Profiles[Player]

	if Profile then
		local Settings = Profile.Data.Settings
		if GamepassService:CheckPass(Player, Setting) then
			if Settings[Setting] ~= nil then
				Profile.Data.Settings[Setting] = Type
				self.Client.UpdateSettings:Fire(Player, Setting, Type)
				self.SettingUpdated:Fire(Player, Setting, Type)

				if Setting == "DisableTips" then
					Player:SetAttribute("ShowTips", not Type)
				end
			else
				Profile.Data.Settings[Setting] = Type
				self.Client.UpdateSettings:Fire(Player, Setting, Type)
				self.SettingUpdated:Fire(Player, Setting, Type)
			end
		else
			Profile.Data.Settings[Setting] = false
			self.Client.UpdateSettings:Fire(Player, Setting, false)
			self.SettingUpdated:Fire(Player, Setting, false)
		end
	end
end

--[[
	Retrieves the settings for a given player.
	Waits until the player's "Loaded" attribute is true, then fetches the player's profile from Knit.
	If the profile exists, it iterates through the settings and updates the player's "ShowTips" attribute based on the "DisableTips" setting.
	Returns the settings table if the profile is found, otherwise returns nil.

	@function GetSettings
	@param Player The player whose settings are being retrieved.
	@within DataService
]]
function DataService:GetSettings(Player)
	repeat
		task.wait()
	until Player:GetAttribute("Loaded")

	local Profile = Knit.Profiles[Player]

	if Profile then
		local Settings = Profile.Data.Settings

		for Setting, Toggle in pairs(Settings) do
			if Setting == "DisableTips" then
				Player:SetAttribute("ShowTips", not Toggle)
            end
		end

		return Settings
	end

	return nil
end

--[[
	Starts the DataService by initializing the RankService, loading player profiles, and checking booster status.
	Connects various player events to handle rank updates, profile loading, and booster status checks.

	@function KnitStart
	@within DataService
]]
function DataService:KnitStart()
	RankService = Knit.GetService("RankService")
	-- GamepassService = Knit.GetService("GamepassService")

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
		if Player.AccountAge < 10 then
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
--[[
	Updates a player's setting on the server.

	@function Update
	@within DataService.Client
	@param Player Player -- The player whose setting is being updated.
	@param Setting string -- The name of the setting to update.
	@param Type boolean -- The new value of the setting.
]]
function DataService.Client:Update(Player: Player, Setting: string, Type: boolean)
	self.Server:UpdateSetting(Player, Setting, Type)
end

--[[
	Retrieves the settings for a given player by calling the Server's GetSettings method.

	@function Get
	@param Player The player for whom the settings are being retrieved.
	@within DataService.Client
]]
function DataService.Client:Get(Player)
	return self.Server:GetSettings(Player)
end

-- ————————— 🂡 —————————
-- Return Service to Knit.
return DataService