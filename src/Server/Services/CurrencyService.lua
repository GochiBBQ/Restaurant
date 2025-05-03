--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local MarketplaceService: MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players: Players = game:GetService("Players")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)

-- Create Knit Service
local CurrencyService = Knit.CreateService({
	Name = "CurrencyService",
	Client = {
		UpdateClient = Knit.CreateSignal(),
	},
})

local productFunctions = {}

-- Variables

local RankService

-- Server Functions
function CurrencyService:KnitStart()
	RankService = Knit.GetService("RankService")
end

function CurrencyService:Get(Player: Player)
	repeat
		task.wait()
	until Player:GetAttribute("Loaded")

	local Profile = Knit.Profiles[Player]

	if Profile then
		local Coins = Profile.Data.Inventory.Currency

		return Coins or 0
	else
		return 0
	end
end

function CurrencyService:Set(Player, Amount)
	repeat
		task.wait()
	until Player:GetAttribute("Loaded")

	local Profile = Knit.Profiles[Player]
	local OldAmount = Profile.Data.Inventory.Currency

	if Profile then
		if Amount >= 0 then
			Profile.Data.Inventory.Currency = tonumber(Amount)
			self.Client.UpdateClient:Fire(Player, OldAmount, self:Get(Player))
		end
	end
end

function CurrencyService:Give(Player, Amount)
	repeat
		task.wait()
	until Player:GetAttribute("Loaded")

	local Profile = Knit.Profiles[Player]
	local OldAmount = Profile.Data.Inventory.Currency

	if Profile then

		Profile.Data.Inventory.Currency += Amount
		self.Client.UpdateClient:Fire(Player, OldAmount, self:Get(Player))
	end
end

function CurrencyService:Remove(Player, Amount)
	repeat
		task.wait()
	until Player:GetAttribute("Loaded")

	local Profile = Knit.Profiles[Player]
	local OldAmount = Profile.Data.Inventory.Currency

	if Profile then
		Profile.Data.Inventory.Currency -= Amount

		if Profile.Data.Inventory.Currency < 0 then
			Profile.Data.Inventory.Currency = 0
		end

		self.Client.UpdateClient:Fire(Player, OldAmount, self:Get(Player))
	end
end

-- Client Functions

function CurrencyService.Client:GetCoins(Player)
	return self.Server:Get(Player)
end

function CurrencyService.Client:GiveCoins(Player, XP)
	self.Server:Give(Player, XP)
end

-- Return Service to Knit.
return CurrencyService