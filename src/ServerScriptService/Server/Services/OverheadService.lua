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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)

local OverheadTemplate = Knit.Static:WaitForChild("GochiOverhead")
local Influental = {}
local HeartID = {}
local Donator = {}

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Service
local OverheadService = Knit.CreateService {
    Name = "OverheadService",
	Client = {
        UpdateOverhead = Knit.CreateSignal(),
	},
}

local RankService

-- ————————— ↢ ⭐️ ↣ —————————-
-- Server Functions
function OverheadService:KnitStart()
	RankService = Knit.GetService("RankService")

	PlayerService.PlayerAdded:Connect(function(Player)
		Player.CharacterAdded:Connect(function(Character)
			if Character:WaitForChild("HumanoidRootPart"):FindFirstChild("GochiOverhead") then
				return
			end

			local humanoid = Character:WaitForChild("Humanoid")
			if humanoid then
				humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
				humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			end

			local Clone = OverheadTemplate:Clone()
			Clone.Parent = Player.Character.HumanoidRootPart
			Clone.Adornee = Player.Character.HumanoidRootPart
			Clone.Name = "GochiOverhead"
			Clone.Username.Text = Player.Name
			Clone.Rank.Text = RankService:GetRole(Player)

			self:InitGradients(Player)
			self:InitBadges(Player)
		end)
	end)
end

function OverheadService:Get(Player)
	if Player.Character:WaitForChild("HumanoidRootPart"):FindFirstChild("GochiOverhead") then
		return Player.Character:WaitForChild("HumanoidRootPart"):FindFirstChild("GochiOverhead")
	end
end

function OverheadService.Client:Get(Player)
	return self.Server:Get(Player)
end

function OverheadService:InitGradients(Player)
	local PlayerProfile = Knit.Profiles[Player]

	if Player.UserId == 106192999 then
		self.Client.UpdateOverhead:Fire(Player, "Arjun")
	elseif PlayerProfile.Data.CurrentNametag then
		self.Client.UpdateOverhead:Fire(Player, PlayerProfile.Data.CurrentNametag)
	end
end

function OverheadService:InitBadges(Player)
	local Overhead = self:Get(Player)
	local Badges = Overhead:WaitForChild("Badges")

	if HeartID[Player.UserId] or RankService:GetRank(Player) >= 225 then
		Badges.Heart.Visible = true
	end

	if Donator[Player.UserId] or RankService:GetRank(Player) >= 225 then
		Badges.Money.Visible = true
	end

	if Influental[Player.UserId] or RankService:GetRank(Player) >= 225 then
		Badges.Check.Visible = true
	end

	if RankService:GetRank(Player) >= 225 then
		Badges.Crown.Visible = true
	end

	if RankService:GetRank(Player) >= 160 then
		Badges.Hammer.Visible = true
	end

	if RankService:GetRank(Player) == 225 or RankService:GetRank(Player) >= 252 then
		Badges.Gear.Visible = true
	end

	if
		RankService:GetRank(Player) == 20
		or RankService:GetRank(Player) == 225
		or RankService:GetRank(Player) >= 252
	then
		Badges.Handshake.Visible = true
	end
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Service to Knit.
return OverheadService