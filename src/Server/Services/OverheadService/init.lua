--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit) -- @module Knit
local AnimNation = require(Knit.Modules.AnimNation) -- @module AnimNation

local BadgeList = require(Knit.Data.BadgesList) -- @module BadgesList
local NametagList = require(Knit.Data.NametagList) -- @module NametagList

-- Variables
local PlayerStorage = workspace:WaitForChild("PlayerStorage")
local NametagTemplate = script.Rank

local RankService
local InventoryService

-- Create Knit Service
local OverheadService = Knit.CreateService({
	Name = "OverheadService",
	Gradients = {},
	Overheads = {},
	Client = {
		Update = Knit.CreateSignal(),
	},
})

-- Server Functions
function OverheadService:KnitStart()
	InventoryService = Knit.GetService("InventoryService")
	RankService = Knit.GetService("RankService")

	Players.PlayerAdded:Connect(function(Player: Player)
		Player.CharacterAdded:Connect(function()
			self:CreateFunction(Player)
		end)

		if not table.find(self.Gradients, Player) then
			self.Gradients[Player] = {}
		end
	end)

	Players.PlayerRemoving:Connect(function(Player: Player)
		if table.find(self.Gradients, Player) then
			self.Gradients[Player] = nil
		end

		if table.find(self.Overheads, Player) then
			if self.Overheads[Player] then
				self.Overheads[Player]:Destroy()
			end
			self.Overheads[Player] = nil
		end
	end)
end

function OverheadService:CreateFunction(Player: Player)
	repeat task.wait() until Player:GetAttribute("Loaded")

	local Character = Player.Character or Player.CharacterAdded:Wait()
	Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	repeat task.wait() until Character:FindFirstChild("Head")
	local ClonedNametag = nil

	if self.Overheads[Player] then
		self.Overheads[Player].Adornee = Character.Head
		ClonedNametag = self.Overheads[Player]
	else
		ClonedNametag = NametagTemplate:Clone()
		ClonedNametag.Main.Username.Text = Player.Name
		ClonedNametag.Main.Rank.Text = RankService:GetRole(Player)
		ClonedNametag.Parent = PlayerStorage:WaitForChild("Nametags"):WaitForChild(Player.Name)
		ClonedNametag.Adornee = Character.Head

		self.Overheads[Player] = ClonedNametag

		local gradient = InventoryService:_getEquipped(Player, "Nametags")

		if gradient then
			self:CreateGradient(Player, tostring(gradient))
		end
		self:TweenFunction(Player)
	end
end

function OverheadService:EligibleBadges(Player: Player)
	local toReturn = {}

	if Player then
		local Rank = RankService:GetRank(Player)

		if Rank == 15 then
			table.insert(toReturn, "DEVELOPER")
		end

		if Rank == 16 then
			table.insert(toReturn, "LEAD DEVELOPER")
		end

		if Rank >= 7 and Rank <= 11 then
			table.insert(toReturn, "MIDDLE RANK")
		end

		if Rank >= 12 and Rank <= 14 then
			table.insert(toReturn, "HIGH RANK")
		end

		if Rank >= 17 and Rank <= 255 then
			table.insert(toReturn, "LEADERSHIP TEAM")
		end

		repeat task.wait() until Player:GetAttribute("Booster") ~= nil

		if Player:GetAttribute("Booster") then
			table.insert(toReturn, "NITRO BOOSTER")
		end
	end

	return toReturn
end

function OverheadService:CreateBadges(Player: Player)
	local Overhead = self.Overheads[Player]
	local Frame = Overhead:WaitForChild("Main")
	local Badges = Frame:WaitForChild("Titles")

	if #Badges:GetChildren() > 1 then
		return true
	else
		local EligibleBadges = self:EligibleBadges(Player)

		local template = Badges:WaitForChild("Template")
		
		for i, badge in next, EligibleBadges do
			local clone = template:Clone()
			
			local BadgeData = BadgeList[badge]

			clone.Name = BadgeData["Title"]
			clone.Title.Text = BadgeData["Title"]
			clone.UIGradient.Color = BadgeData["Color"]
			clone.Parent = Badges

			task.spawn(function()
				local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Bounce, Enum.EasingDirection.In, -1, false)
				local tween = TweenService:Create(clone.UIGradient, tweenInfo, { Offset = Vector2.new(1, 0) })
				tween:Play()
			end)
		end
		return true
	end
end

function OverheadService:CreateGradient(Player: Player, Gradient: string)

	repeat task.wait() until Player:GetAttribute("Loaded") and self.Overheads[Player]

	local Overhead = self.Overheads[Player]
	local Frame = Overhead:WaitForChild("Main")

	task.spawn(function()
		if NametagList[Gradient] then
			if self.Gradients[Player] then
				self.Gradients[Player] = {}
	
				local gradient = Instance.new("UIGradient")
				gradient.Parent = Frame.Username
	
				gradient.Name = Gradient
	
				if NametagList[Gradient]["Rotation"] then
					gradient.Rotation = NametagList[Gradient]["Rotation"]
				end
	
				local GradientTime
	
				if NametagList[Gradient]["Time"] then
					GradientTime = NametagList[Gradient]["Time"]
				else
					GradientTime = 4
				end
				
				self.Gradients[Player] = gradient
				
				local NumColors = #NametagList[Gradient]["Colors"]
				local ColorLength = 1 / NumColors
				
				RunService.Heartbeat:Connect(function()
				   local progress = (tick() % GradientTime) / GradientTime
				   local NewColors = {}
				   local WrapColor = false
					
					for i = 1, NumColors + 1 do
						local color = NametagList[Gradient]["Colors"][i] or NametagList[Gradient]["Colors"][i-NumColors]
						local position = progress + (i-1)/NumColors
				
						if position > 1 then position = position - 1 end
						if position == 0 or position == 1 then WrapColor = true end
						
						table.insert(NewColors, ColorSequenceKeypoint.new(position, color))
				   end
				
					if not WrapColor then
						local IndexProgress = ((1 - progress) / ColorLength) + 1
						local Color1 = NametagList[Gradient]["Colors"][math.floor(IndexProgress)]
						local Color2 = NametagList[Gradient]["Colors"][math.ceil(IndexProgress)] or NametagList[Gradient]["Colors"][1]
						local FinalColors = Color1:Lerp(Color2, IndexProgress % 1)
						
						table.insert(NewColors, ColorSequenceKeypoint.new(0, FinalColors))
						table.insert(NewColors, ColorSequenceKeypoint.new(1, FinalColors))
					end
					
					table.sort(NewColors, function(a, b)
						return a.Time < b.Time
					end)
					
					gradient.Color = ColorSequence.new(NewColors)
				end)
			end
		end
	end)
end

function OverheadService:StopGradient(Player: Player)
	if self.Gradients[Player] then
		local gradient = self.Gradients[Player]
		if typeof(gradient) == "Instance" then
			gradient:Destroy()
		end
		self.Gradients[Player] = {}
	end
end

function OverheadService:TweenFunction(Player: Player)
	local Overhead = self.Overheads[Player]:WaitForChild("Main")
	local result = self:CreateBadges(Player)

	if result then
		local Badges = Overhead:WaitForChild("Titles")

		task.spawn(function()
			while task.wait() do
				if #Badges:GetChildren() > 1 then
					for _, Badge in next, Badges:GetChildren() do
						if Badge.Name ~= "Template" then
							Badge.Visible = true
							-- Load in first badge
							AnimNation.target(Badge, {s = 20}, {BackgroundTransparency = 0})
							AnimNation.target(Badge.Title, {s = 20}, {TextTransparency = 0})
							task.wait(5)

							-- Fade out first badge
							AnimNation.target(Badge, {s = 20}, {BackgroundTransparency = 1})
							AnimNation.target(Badge.Title, {s = 20}, {TextTransparency = 1})
							task.wait(0.3)
							Badge.Visible = false
						end
					end
				else
					if Badges:GetChildren() then
						for _, badge in next, Badges:GetChildren() do
							if badge.Name ~= "Template" then
								AnimNation.target(badge, {s = 20}, {BackgroundTransparency = 0})
								AnimNation.target(badge.Title, {s = 20}, {TextTransparency = 0})
							end
						end
					end
				end
			end
		end)
	end
end


-- Return service to Knit
return OverheadService
