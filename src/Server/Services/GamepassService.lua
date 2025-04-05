--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableMap = require(Knit.Structures.TableMap) --- @module TableMap

-- Create Knit Service
local GamepassService = Knit.CreateService {
	Name = "GamepassService",
	Client = {
		UpdateSettings = Knit.CreateSignal(),
	},
	SettingUpdated = Signal.new(),
}

local Gamepasses = {
	["Headless"] = { ID = 1002697699 },
	["Korblox"] = { ID = 1004797619 },
	["Walkspeed"] = { ID = 1003057662 },
	["DisableUniform"] = { ID = 1003177642 },
}

-- Variables
local OwnedGamepasses = TableMap.new() -- UserId → list of passes
local RankService

-- Server Functions
function GamepassService:KnitStart()
	RankService = Knit.GetService("RankService")

	Players.PlayerAdded:Connect(function(Player)
		self:HandlePlayerAdded(Player)
	end)

	Players.PlayerRemoving:Connect(function(Player)
		OwnedGamepasses:remove(Player.UserId)
	end)

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(Player, GamepassID, wasPurchased)
		if wasPurchased then
			self:HandleGamePassPurchase(Player, GamepassID)
		end
	end)
end

function GamepassService:HandlePlayerAdded(Player)
	local passes = {}

	-- Check owned gamepasses on player join
	for gamepass, data in pairs(Gamepasses) do
		local ID = data.ID
		if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, ID) or RankService:GetRank(Player) >= 16 then
			table.insert(passes, gamepass)
		end
	end

	OwnedGamepasses:set(Player.UserId, passes)

	-- Listen for character added to apply gamepasses
	Player.CharacterAdded:Connect(function(character)
		self:InitializeGamepasses(Player)
	end)

	-- Initialize immediately if character exists
	if Player.Character then
		self:InitializeGamepasses(Player)
	end
end

function GamepassService:InitializeGamepasses(Player)
	local passes = OwnedGamepasses:get(Player.UserId)
	if not passes then return end

	for _, gamepass in ipairs(passes) do
		if gamepass == "Walkspeed" then
			self:InitWalkspeed(Player, true)
		elseif gamepass == "Headless" then
			self:InitHeadless(Player, true)
		elseif gamepass == "Korblox" then
			self:InitKorblox(Player, true)
		elseif gamepass == "DisableUniform" then
			self:InitUniform(Player, true)
		end
	end
end

function GamepassService:GetGamepasses(Player)
	while not Player:GetAttribute("Loaded") do task.wait() end

	local Profile = Knit.Profiles[Player]
	if not Profile then return nil end

	local Gamepasses = Profile.Data.Settings['Gamepasses']

	for gamepass, toggle in pairs(Gamepasses) do
		if toggle then
			self:HandleGamePassUpdated(Player, gamepass, true)
		end
	end

	return Gamepasses
end

function GamepassService:UpdateGamepass(Player: Player, Gamepass: string, Type: boolean)
	local Profile = Knit.Profiles[Player]
	if not Profile then return end

	local Settings = Profile.Data.Settings['Gamepasses']
	if self:CheckPass(Player, Gamepass) then
		Settings[Gamepass] = Type
		self.Client.UpdateSettings:Fire(Player, Gamepass, Type)
		self.SettingUpdated:Fire(Player, Gamepass, Type)
		self:HandleGamePassUpdated(Player, Gamepass, Type)
	else
		Settings[Gamepass] = false
		self.Client.UpdateSettings:Fire(Player, Gamepass, false)
		self.SettingUpdated:Fire(Player, Gamepass, false)
	end
end

function GamepassService:HandleGamePassPurchase(Player, GamepassID)
	local passes = OwnedGamepasses:get(Player.UserId) or {}
	for name, data in pairs(Gamepasses) do
		if data.ID == GamepassID then
			table.insert(passes, name)
			OwnedGamepasses:set(Player.UserId, passes)

			self:UpdateGamepass(Player, name, true)
			self:HandleGamePassUpdated(Player, name, true)
			break
		end
	end
end

function GamepassService:HandleGamePassUpdated(Player, Gamepass, Toggle)
	if Gamepass == "Walkspeed" then
		self:InitWalkspeed(Player, Toggle)
	elseif Gamepass == "Headless" then
		self:InitHeadless(Player, Toggle)
	elseif Gamepass == "Korblox" then
		self:InitKorblox(Player, Toggle)
	elseif Gamepass == "DisableUniform" then
		self:InitUniform(Player, Toggle)
	end
end

function GamepassService:InitUniform(Player, Action)
	if self:CheckPass(Player, "DisableUniform") and RankService:GetRank(Player) < 7 then
		local character = Player.Character or Player.CharacterAdded:Wait()
		local humanoid = character:FindFirstChild("Humanoid")
		if Action and humanoid then
			local desc = Players:GetHumanoidDescriptionFromUserId(Player.UserId)
			humanoid:ApplyDescription(desc)
		end
	end
end

function GamepassService:InitWalkspeed(Player, Action)
	if self:CheckPass(Player, "Walkspeed") then
		local character = Player.Character or Player.CharacterAdded:Wait()
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			Player:SetAttribute("Walkspeed", Action)
			humanoid.WalkSpeed = Action and 32 or 16
		end
	end
end

function GamepassService:InitHeadless(Player, Action)
	if self:CheckPass(Player, "Headless") then
		local character = Player.Character or Player.CharacterAdded:Wait()
		local head = character:FindFirstChild("Head")
		local face = head and head:FindFirstChild("face")

		if head then head.Transparency = Action and 1 or 0 end
		if face then face.Face = Action and "Bottom" or "Front" end
	end
end

function GamepassService:InitKorblox(Player, Action)
	if self:CheckPass(Player, "Korblox") then
		local character = Player.Character or Player.CharacterAdded:Wait()
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			local desc = Action and humanoid:GetAppliedDescription() or Players:GetHumanoidDescriptionFromUserId(Player.UserId)
			if Action then desc.RightLeg = 139607718 end
			humanoid:ApplyDescription(desc)
		end
	end
end

function GamepassService:CheckPass(Player, Pass)
	while not Player:GetAttribute("Loaded") do task.wait() end
	local passes = OwnedGamepasses:get(Player.UserId)
	return passes and table.find(passes, Pass)
end

-- Client Functions
function GamepassService.Client:Check(Player, Pass)
	return self.Server:CheckPass(Player, Pass)
end

function GamepassService.Client:Update(Player: Player, Gamepass: string, Type: boolean)
	self.Server:UpdateGamepass(Player, Gamepass, Type)
end

function GamepassService.Client:Get(Player)
	return self.Server:GetGamepasses(Player)
end

-- Return Service to Knit
return GamepassService
