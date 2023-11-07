local IsServer = game:GetService("RunService"):IsServer() and true or false
local GamepassTools = game:GetService("ServerStorage"):WaitForChild("GamepassTools")
local MarketplaceService = game:GetService("MarketplaceService")

return {
	[13588848] = {
		["Name"] = "Disable Uniform",
		["Desc"] = MarketplaceService:GetProductInfo(13588848, Enum.InfoType.GamePass).Description,
		["Image"] = "http://www.roblox.com/asset/?id=" .. MarketplaceService:GetProductInfo(13588848, Enum.InfoType.GamePass).IconImageAssetId,
		["CanPurchase"] = MarketplaceService:GetProductInfo(13588848, Enum.InfoType.GamePass).IsForSale,
		["RunOnRespawn"] = false
	},
	[13588873] = {
		["Name"] = "Rainbow Nametag",
		["Desc"] = MarketplaceService:GetProductInfo(13588873, Enum.InfoType.GamePass).Description,
		["Image"] = "http://www.roblox.com/asset/?id=" .. MarketplaceService:GetProductInfo(13588873, Enum.InfoType.GamePass).IconImageAssetId,
		["CanPurchase"] = MarketplaceService:GetProductInfo(13588873, Enum.InfoType.GamePass).IsForSale,
		["RunOnRespawn"] = false
	},
	[13588891] = {
		["Name"] = "Faster Walkspeed",
		["Desc"] = MarketplaceService:GetProductInfo(13588891, Enum.InfoType.GamePass).Description,
		["Image"] = "http://www.roblox.com/asset/?id=" .. MarketplaceService:GetProductInfo(13588891, Enum.InfoType.GamePass).IconImageAssetId,
		["CanPurchase"] = MarketplaceService:GetProductInfo(13588891, Enum.InfoType.GamePass).IsForSale,
		["RunOnRespawn"] = false
	}
}