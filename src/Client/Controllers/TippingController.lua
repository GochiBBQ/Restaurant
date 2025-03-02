--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local spr = require(Knit.Modules.spr)

-- Create Knit Controller
local TippingController = Knit.CreateController {
    Name = "TippingController",
    IngamePlayers = {},
}

-- Variables
local Player = Players.LocalPlayer
local Camera = workspace:WaitForChild("Camera")

local PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI = PlayerGui:WaitForChild("GochiUI")
local TippingUI = GochiUI:WaitForChild("Tipping")
local TipsContainer = TippingUI:WaitForChild("Content"):WaitForChild("List")

local TippingService, RankService, NotificationService
local UIController

-- Client Functions
function TippingController:KnitStart()
    TippingService, RankService = Knit.GetService("TippingService"), Knit.GetService("RankService")
    UIController = Knit.GetController("UIController")

    Players.PlayerAdded:Connect(function(Player)
        self.IngamePlayers[Player] = {Rank = Player:GetRankInGroup(5874921)}
    end)

    Players.PlayerRemoving:Connect(function(Player)
        self.IngamePlayers[Player] = nil
    end)

    for _, Player in pairs(Players:GetPlayers()) do
        if self.IngamePlayers[Player] == nil then
            self.IngamePlayers[Player] = {Rank = Player:GetRankInGroup(5874921)}
        end
    end

    TippingUI.Content.Close.MouseButton1Click:Connect(function()
        UIController:Close(TippingUI)
    end)

    RunService:BindToRenderStep("TippingPrompts", 0, function()
        local CurrentPlayers = Players:GetPlayers()

        for _, player in ipairs(CurrentPlayers) do
            if player and player:GetAttribute("Loaded") and self.IngamePlayers[player] ~= nil then
                if self.IngamePlayers[player].Rank >= 4 and player ~= Player then
                    local Character = player.Character or player.CharacterAdded:Wait()
                    if Character ~= nil then
                        local HumanoidRootPart = Character:WaitForChild('HumanoidRootPart')
                        local ProximityPrompt = HumanoidRootPart:FindFirstChild("TippingPrompt")
                        if ProximityPrompt then
                            if player:GetAttribute("TipsEnabled") and Player:GetAttribute("ShowTips") then
                                ProximityPrompt.Enabled = true
                            else
                                ProximityPrompt.Enabled = false
                            end
                        else
                            ProximityPrompt = Instance.new("ProximityPrompt")
                            ProximityPrompt.Name = "TippingPrompt"

                            ProximityPrompt.Style = Enum.ProximityPromptStyle.Custom
                            ProximityPrompt:SetAttribute("Theme", "Default")
                            ProximityPrompt.RequiresLineOfSight = false
                            ProximityPrompt.ObjectText = "Tip"
                            ProximityPrompt.ActionText = player.Name
                            ProximityPrompt.MaxActivationDistance = 10

                            ProximityPrompt.Parent = Character:WaitForChild("HumanoidRootPart")

                            ProximityPrompt.Triggered:Connect(function()
                                if not TippingUI.Visible then
                                    self:UpdateTips(player)
                                    UIController:Open(TippingUI)
                                end
                            end)

                            if player:GetAttribute("TipsEnabled") and Player:GetAttribute("ShowTips") then
                                ProximityPrompt.Enabled = true
                            else
                                ProximityPrompt.Enabled = false
                            end
                        end
                    end
                end
            end
        end
    end)
end

function TippingController:UpdateTips(player: Player)
    for _, v in ipairs(TipsContainer:GetChildren()) do
        if v.ClassName ~= "UIListLayout" and v.ClassName ~= "UIPadding" and v.Name ~= "Template" and v.Name ~= "Zend" then
            v:Destroy()
        end
    end

    TippingService:GetTips(player):andThen(function(Tips)
        if Tips ~= nil then
            TipsContainer.ScrollingEnabled = true
            TipsContainer.ScrollBarImageTransparency = 0

            -- Sort tips by price in ascending order
            table.sort(Tips, function(a, b)
                return tonumber(a[2]) < tonumber(b[2])
            end)

            for i, v in ipairs(Tips) do
                local Price = v[2]
                local GamepassId = v[1]

                local Frame = TipsContainer.Template:Clone()
                Frame.Name = Price
                Frame.LayoutOrder = i
                Frame.Value.Text = Price
                Frame.Parent = TipsContainer
                Frame.Purchase.Position = UDim2.new(1, 2, 0.5, 0)
                Frame.Visible = true

                Frame.Purchase.MouseEnter:Connect(function()
                    Frame.UIGradient.Enabled = true
                    Frame.UIStroke.UIGradient.Enabled = true
                end)

                Frame.Purchase.MouseLeave:Connect(function()
                    Frame.UIGradient.Enabled = false
                    Frame.UIStroke.UIGradient.Enabled = false
                end)

                Frame.Purchase.MouseButton1Click:Connect(function()
                    MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, GamepassId)
                end)
            end
        end
    end)
    TipsContainer.Parent.Title.Text = `Would you like to tip <font weight ="Bold">{player.Name}</font> for your service today?`
end

-- Return Controller to Knit.
return TippingController