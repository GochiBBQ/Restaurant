--[[
Author: alreadyfans
For: Gochi
]]

-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TipUtil = require(ReplicatedStorage.Util.TipUtil)
local TableMap = require(Knit.Structures.TableMap) --- @module TableMap

-- Create Knit Service
local TippingService = Knit.CreateService {
	Name = "TippingService",
	Client = {
		Notification = Knit.CreateSignal()
	},
}

-- Variables
local url = "http://138.197.80.59:3001"
local key = `QJvdks3RUn6vklV1G2kQPsUsclZxvDzd`

local TopTippers = DataStoreService:GetOrderedDataStore("TopTippers")
local TopReceivers = DataStoreService:GetOrderedDataStore("TopReceivers")

local PassesToPlayers = TableMap.new() -- gamePassId → Player
local PlayerTroveMap = TableMap.new() -- Player → Trove

local RankService, NotificationService

-- Server Functions
function TippingService:HandlePlayer(Player: Player)
	local Rank = RankService:GetRank(Player)
	if Rank < 4 then return end

	local Profile = Knit.Profiles[Player]
	if not Profile then return end

	local trove = PlayerTroveMap:get(Player)
	if not trove then
		trove = Trove.new()
		PlayerTroveMap:set(Player, trove)
	else
		trove:Clean()
	end

	if #Profile.Data.Gamepasses < 1 then
		local gamepasses = TipUtil:GetUserGamepasses(Player.UserId)
		Profile.Data.Gamepasses = gamepasses
	end

	for _, passId in Profile.Data.Gamepasses do
		PassesToPlayers:set(passId, Player)
		trove:Add(function()
			if PassesToPlayers:get(passId) == Player then
				PassesToPlayers:remove(passId)
			end
		end)
	end

	Player:SetAttribute("TipsEnabled", #Profile.Data.Gamepasses > 0)
end

function TippingService:KnitStart()
	RankService = Knit.GetService("RankService")
	NotificationService = Knit.GetService("NotificationService")

	Players.PlayerAdded:Connect(function(Player)
		self:HandlePlayer(Player)
	end)

	for _, Player in Players:GetPlayers() do
		self:HandlePlayer(Player)
	end

	Players.PlayerRemoving:Connect(function(Player)
		local trove = PlayerTroveMap:get(Player)
		if trove then
			trove:Destroy()
			PlayerTroveMap:remove(Player)
		end
	end)

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
		if not wasPurchased then return end

		local receiver = PassesToPlayers:get(gamePassId)
		if not receiver then return end

		local productInfo = MarketplaceService:GetProductInfo(gamePassId, Enum.InfoType.GamePass)
		local price = productInfo.PriceInRobux or 0

		NotificationService:CreateAnnouncement(
			`<b>{player.Name}</b> has tipped <b>{receiver.Name} {price}</b> robux!`
		)

		self:Update(TopTippers, player.UserId, price)
		self:Update(TopReceivers, receiver.UserId, price)
		self:Log(player, gamePassId, price)
	end)
end

function TippingService:Log(Player: Player, GamepassID: number, Price: number)
	local ProductInfo = MarketplaceService:GetProductInfo(GamepassID, Enum.InfoType.GamePass)

	local info = {
		tipper = Player.Name,
		receiver = ProductInfo.Creator.Name,
		amount = Price,
	}

	local success, response = pcall(HttpService.RequestAsync, HttpService, {
		Url = ("%s/tip"):format(url),
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json",
			["Authorization"] = key,
		},
		Body = HttpService:JSONEncode(info)
	})

	if success then
		local result = HttpService:JSONDecode(response.Body)
		if not result.success then
			warn(("Error with %d: %s"):format(Player.UserId, result.msg))
		end
	else
		warn("Failed to send tip log request.")
	end
end

function TippingService:Update(Datastore: DataStore, UserId: string, Amount: number)
	Datastore:IncrementAsync(UserId, Amount)
end

function TippingService:Get(player: Player)
	local playerPasses = {}
	for passId, passPlayer in PassesToPlayers:entries() do
		if passPlayer == player then
			table.insert(playerPasses, passId)
		end
	end
	return playerPasses
end

-- Client Functions
function TippingService.Client:GetTips(_initiator: Player, player: Player)
	return self.Server:Get(player)
end

-- Return Service to Knit
return TippingService
