--[[

Author: alreadyfans
For: Gochi

]]

-- ————————— 🂡 —————————
-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- ————————— 🂡 —————————
-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local AnimNation = require(Knit.Modules.AnimNation) -- @module AnimNation
-- local spr = require(Knit.Modules.spr)

local Badges = require(ReplicatedStorage.Data.BadgesList)

-- ————————— 🂡 —————————
-- Variables

local RankService

local NametagTemplate = script.Rank
local PlayerCache = {}
local Times = {}
local player = {}

-- ————————— 🂡 —————————
-- Create Knit Service
local OverheadService = Knit.CreateService({
	Name = "OverheadService",
	Client = {},
})

-- ————————— 🂡 —————————
-- Server Functions

function OverheadService:KnitStart()
	RankService = Knit.GetService("RankService")

	Players.PlayerAdded:Connect(function(Player)
		Player.CharacterAdded:Connect(function()
			repeat
				task.wait()
			until Player:GetAttribute("Loaded")

			local Character = Player.Character or Player.CharacterAdded:Wait()
			Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			repeat
				task.wait()
			until Character.Head
			local ClonedNametag = nil

			-- Caches nametags to be referenced more than once
			if PlayerCache[Player] then
				PlayerCache[Player].Adornee = Character.Head
				ClonedNametag = PlayerCache[Player]
			else
				ClonedNametag = NametagTemplate:Clone()
				ClonedNametag.Parent = workspace:WaitForChild("Nametags")
				ClonedNametag.Name = Player.UserId
				ClonedNametag.Adornee = Character.Head
				PlayerCache[Player] = ClonedNametag
			end

			ClonedNametag.Main.Username.Text = Player.Name
			ClonedNametag.Main.Rank.Text = RankService:GetRole(Player)

			-- Provides nametag colors
			if Player.UserId == 106192999 then -- arjun
				ClonedNametag.Main.Username.TextColor3 = Color3.fromHex("89cff0")
			end

			-- Badges

            Times[Player] = 0
            local num = 0

			local Rank = RankService:GetRank(Player)

            local function addBadge(badgeTitle, badgeColor)
                local Badge = ClonedNametag.Main.Titles.Template:Clone()
                Badge.Title.Text = badgeTitle
                Badge.UIGradient.Color = badgeColor
                Badge.Parent = ClonedNametag.Main.Titles

                num += 1
                Badge.Name = `Top{num}`

                task.spawn(function()
                    local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Bounce, Enum.EasingDirection.In, -1, false)
                    local tween = TweenService:Create(Badge.UIGradient, tweenInfo, { Offset = Vector2.new(1, 0) })
                    tween:Play()
                end)
                
            end

			if Rank >= 15 and Rank <= 16 then
				addBadge(Badges["DEVELOPER"].Title, Badges["DEVELOPER"].Color)
			end

			if Rank == 16 then
                addBadge(Badges["LEAD DEVELOPER"].Title, Badges["LEAD DEVELOPER"].Color)
			end

			if Rank >= 7 and Rank <= 11 then
                addBadge(Badges["MIDDLE RANK"].Title, Badges["MIDDLE RANK"].Color)
			end

			if Rank >= 12 and Rank <= 14 then
                addBadge(Badges["HIGH RANK"].Title, Badges["HIGH RANK"].Color)
			end

			if Rank >= 17 and Rank <= 255 then
                addBadge(Badges["LEADERSHIP TEAM"].Title, Badges["LEADERSHIP TEAM"].Color)
			end

			task.spawn(function()
				repeat
					task.wait()
				until Player:GetAttribute("Booster") ~= nil

				if Player:GetAttribute("Booster") then
                    addBadge(Badges["NITRO BOOSTER"].Title, Badges["NITRO BOOSTER"].Color)
				end

				-- TODO: VIP
			end)

            player[Player] = #ClonedNametag.Main.Titles:GetChildren()
		end)
	end)

	Players.PlayerRemoving:Connect(function(Player)
		if PlayerCache[Player] then
			PlayerCache[Player]:Destroy()
		end
	end)

    task.spawn(function()
        while true do
            for _, Player in next, Players:GetPlayers() do
                local badgeCount = player[Player] - 1
                local nametag = PlayerCache[Player]

                if badgeCount then
                    local function showBadge(badge)
                        if badge and badge:FindFirstChild("Title") then
                            AnimNation.target(badge, {s = 8}, {BackgroundTransparency = 0})
                            AnimNation.target(badge.Title, {s = 8}, {TextTransparency = 0})
                            AnimNation.target(badge.Title, {s = 8}, {TextStrokeTransparency = 0.8})
                            -- spr.target(badge, 1, 1, { BackgroundTransparency = 0 })
                            -- spr.target(badge.Title, 1, 1, { TextTransparency = 0 })
                            -- spr.target(badge.Title, 1, 1, { TextStrokeTransparency = 0.8 })
                        end
                    end

                    local function hideAllBadges()
                        for _, otherBadge in next, nametag.Main.Titles:GetChildren() do
                            if otherBadge and otherBadge:FindFirstChild("Title") then
                                AnimNation.target(otherBadge, {s = 8}, {BackgroundTransparency = 1})
                                AnimNation.target(otherBadge.Title, {s = 8}, {TextTransparency = 1})
                                AnimNation.target(otherBadge.Title, {s = 8}, {TextStrokeTransparency = 1})
                                -- spr.target(otherBadge, 1, 1, { BackgroundTransparency = 1 })
                                -- spr.target(otherBadge.Title, 1, 1, { TextTransparency = 1 })
                                -- spr.target(otherBadge.Title, 1, 1, { TextStrokeTransparency = 1 })
                            end
                            task.wait()
                        end
                    end

                    if badgeCount == 1 then
                        showBadge(nametag.Main.Titles['Top1'])
                    elseif badgeCount > 1 then
                        for index, badge in next, nametag.Main.Titles:GetChildren() do
                            if index - 1 == badgeCount then
                                if Times[Player] == #nametag.Main.Titles:GetChildren() - 1 then
                                    Times[Player] = 0
                                end
                                Times[Player] += 1
                                hideAllBadges()

                                if Times[Player] == #nametag.Main.Titles:GetChildren() then
                                    Times[Player] = 0
                                end

                                showBadge(nametag.Main.Titles[`Top{Times[Player]}`])
                            end
                        end
                    end
                end
            end
            task.wait(5)
        end
    end)
    
end

-- ————————— 🂡 —————————
-- Return Service to Knit.
return OverheadService
