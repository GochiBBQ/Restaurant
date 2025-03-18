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
local spr = require(Knit.Modules.spr)

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
			for _, Player in ipairs(Players:GetPlayers()) do
				local badgeCount = (player[Player] or 0) - 1
				local nametag = PlayerCache[Player]
	
				if nametag and badgeCount >= 0 then
					Times[Player] = Times[Player] or 0 -- Initialize if nil
	
					local titleCount = #nametag.Main.Titles:GetChildren()
					if titleCount > 0 then
						-- Get the previously active badge (if any)
						local previousBadge = nametag.Main.Titles:FindFirstChild("Top" .. Times[Player])
	
						-- Cycle to the next badge
						Times[Player] = (Times[Player] % titleCount) + 1
						local newBadge = nametag.Main.Titles:FindFirstChild("Top" .. Times[Player])
	
						-- Fade out the previous badge (if exists) concurrently
						if previousBadge then
							task.spawn(function()
								spr.target(previousBadge, 0.3, 0.3, { BackgroundTransparency = 1 })
								spr.target(previousBadge.Title, 0.3, 0.3, { TextTransparency = 1 })
								spr.target(previousBadge.Title, 0.3, 0.3, { TextStrokeTransparency = 1 })
								task.wait(0.3) -- Add delay to ensure smooth transition
							end)
						end
	
						-- Fade in the new badge
						if newBadge then
							task.spawn(function()
								task.wait(0.3) -- Add delay to ensure smooth transition
								spr.target(newBadge, 0.3, 0.3, { BackgroundTransparency = 0 })
								spr.target(newBadge.Title, 0.3, 0.3, { TextTransparency = 0 })
								spr.target(newBadge.Title, 0.3, 0.3, { TextStrokeTransparency = 0.8 })
							end)
						end
					end
				end
			end
			task.wait(3) -- Shorter wait for a faster cycle
		end
	end)

end

-- ————————— 🂡 —————————
-- Return Service to Knit.
return OverheadService
