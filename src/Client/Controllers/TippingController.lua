--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local MarketplaceService: MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService: RunService = game:GetService("RunService")
local Players: Players = game:GetService("Players")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)
local Trove: ModuleScript = require(ReplicatedStorage.Packages.Trove) --- @module Trove

-- Create Knit Controller
local TippingController = Knit.CreateController {
	Name = "TippingController",
	IngamePlayers = {},
}

-- Variables
local Player: Player = Players.LocalPlayer
local Camera: Camera = workspace:WaitForChild("Camera")

local PlayerGui: PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI: GuiObject = PlayerGui:WaitForChild("GochiUI")
local TippingUI: GuiObject = GochiUI:WaitForChild("Tipping")
local TipsContainer: GuiObject = TippingUI:WaitForChild("Content"):WaitForChild("List")

local TippingService, RankService, NotificationService
local UIController

-- Trove instance
local trove = Trove.new()

-- Client Functions
function TippingController:KnitStart()
	TippingService = Knit.GetService("TippingService")
	RankService = Knit.GetService("RankService")
	UIController = Knit.GetController("UIController")

	trove:Connect(Players.PlayerAdded, function(player)
		self.IngamePlayers[player] = { Rank = player:GetRankInGroup(5874921) }
	end)

	trove:Connect(Players.PlayerRemoving, function(player)
		self.IngamePlayers[player] = nil
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		if not self.IngamePlayers[player] then
			self.IngamePlayers[player] = { Rank = player:GetRankInGroup(5874921) }
		end
	end

	local lastUpdate = 0
	local updateInterval = 0.5 -- every 0.5 seconds

	RunService:BindToRenderStep("TippingPrompts", Enum.RenderPriority.Last.Value, function(dt)
		lastUpdate += dt
		if lastUpdate < updateInterval then return end
		lastUpdate = 0

		for _, player in ipairs(Players:GetPlayers()) do
			if player and player:GetAttribute("Loaded") and self.IngamePlayers[player] then
				if self.IngamePlayers[player].Rank >= 4 and player ~= Player then
					local character = player.Character or player.CharacterAdded:Wait()
					local root = character:FindFirstChild("HumanoidRootPart")

					if root then
						local prompt = root:FindFirstChild("TippingPrompt")
						if not prompt then
							prompt = Instance.new("ProximityPrompt")
							prompt.Name = "TippingPrompt"
							prompt.Style = Enum.ProximityPromptStyle.Custom
							prompt:SetAttribute("Theme", "Default")
							prompt.RequiresLineOfSight = false
							prompt.ObjectText = "Tip"
							prompt.ActionText = player.Name
							prompt.MaxActivationDistance = 10
							prompt.Parent = root
						end

						if not prompt:GetAttribute("Connected") then
							prompt:SetAttribute("Connected", true)
							trove:Connect(prompt.Triggered, function()
								if not TippingUI.Visible or TippingUI:GetAttribute("CurrentTarget") ~= player then
									self:UpdateTips(player)
									UIController:Open(TippingUI)
									TippingUI:SetAttribute("CurrentTarget", player)
								end
							end)
						end

						prompt.Enabled = player:GetAttribute("TipsEnabled") and Player:GetAttribute("ShowTips")
					end
				end
			end
		end
	end)
end

function TippingController:UpdateTips(player: Player)
	trove:Clean() -- clean previous tip button connections

	for _, v in ipairs(TipsContainer:GetChildren()) do
		if v:IsA("Frame") and v.Name ~= "Template" and v.Name ~= "Zend" then
			v:Destroy()
		end
	end

	TippingService:GetTips(player):andThen(function(Tips)
		if not Tips then return end

		TipsContainer.ScrollingEnabled = true
		TipsContainer.ScrollBarImageTransparency = 0

		for _, passId in Tips do
			local frame = TipsContainer.Template:Clone()
			local success, info = pcall(function()
				return MarketplaceService:GetProductInfo(passId, Enum.InfoType.GamePass)
			end)

			if not success or not info or not info.PriceInRobux then
				continue
			end

			local price = info.PriceInRobux

			frame.Name = tostring(price)
			frame.Value.Text = tostring(price)
			frame.LayoutOrder = price
			frame.Visible = true
			frame.Parent = TipsContainer
			frame.Purchase.Position = UDim2.new(1, 2, 0.5, 0)

			trove:Connect(frame.Purchase.Activated, function()
				MarketplaceService:PromptGamePassPurchase(Player, passId)
			end)

			trove:Connect(frame.Purchase.MouseEnter, function()
				frame.UIGradient.Enabled = true
				frame.UIStroke.UIGradient.Enabled = true
			end)

			trove:Connect(frame.Purchase.MouseLeave, function()
				frame.UIGradient.Enabled = false
				frame.UIStroke.UIGradient.Enabled = false
			end)
		end

		trove:Connect(TippingUI.Close.Activated, function()
			UIController:Close(TippingUI)
		end)

		trove:Connect(TippingUI.Content.Close.Activated, function()
			UIController:Close(TippingUI)
		end)
	end)

	TipsContainer.Parent.Title.Text = `Would you like to tip <font weight ="Bold">{player.Name}</font> for your service today?`
end

-- Return Controller to Knit.
return TippingController
