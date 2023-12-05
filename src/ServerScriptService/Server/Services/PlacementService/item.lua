--[[
    __ __  _   _  _   _  ___  __  __  __  _  
    |  V  || \ / || \ / || _ \/ _]/  \|  \| | 
    | \_/ |`\ V /'`\ V /'| v / [/\ /\ | | ' | 
    |_| |_|  \_/    \_/  |_|_\\__/_||_|_|\__| 

    Author: mvvrgan
    For: Sakura Kitchen 🥢
    https://www.roblox.com/groups/6975354/Sakura-Kitchen#!/about

]]

-- ————————— ↢ ⭐️ ↣ —————————
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPack = game:GetService("StarterPack")

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables
local spr = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("spr"))

local item = {}
item.__index = item

-- ————————— ↢ ⭐️ ↣ —————————
-- Server Functions
function item.new(Tool: Tool, PlacementCFrame: CFrame, PlayerPlaced: Player, PlayerFor:Player?)
	local self = {
		Tool = Tool,
		PlacementCFrame = PlacementCFrame,
		PlayerPlaced = PlayerPlaced,
		PlayerFor = PlayerFor,
		PlayerPickedUp = Instance.new("BindableEvent"),
	}

	return setmetatable(self, item)
end

function item:Place(ItemCFrame: CFrame)
    self:SetModel(self.Tool.Model:Clone())

	self.Model.PrimaryPart.Anchored = true
    self.Model.Parent = workspace.Placement.PlacedObjects
    self.Model:PivotTo(ItemCFrame)
	--spr.target(self.Model.PrimaryPart, 0.5, 1.5, { CFrame = self.Model.PrimaryPart.CFrame + Vector3.new(0, 3, 0)})
end

function item:Pickup(Player: Player)
	self.PlayerPickedUp:Fire(Player)
	self.Model:Destroy()
	self.Tool.Parent = Player.Backpack
end

function item:SetModel(model: Model)
    model.Parent = workspace.Placement.PrePlacedObjects
    for _, Part in ipairs(model:GetDescendants()) do
		if Part:IsA("BasePart") then
			Part.Anchored = true
		elseif Part:IsA("Weld") then
			Part:Destroy()
		end
	end

	local Highlight = Instance.new("Highlight")
	Highlight.FillTransparency = 1
	Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	Highlight.Parent = model

	local ProximityPrompt = Instance.new("ProximityPrompt")
	ProximityPrompt.Parent = model
	ProximityPrompt.HoldDuration = 0
	ProximityPrompt.ObjectText = "Pickup "..self.Tool.Name.."!"
	self.ProximityPrompt = ProximityPrompt

	ProximityPrompt.Triggered:Connect(function(Player)
		if self.PlayerFor then
			if self.PlayerFor == self.Player then
				self:Pickup(Player)
			else
				warn("Player "..Player.Name.." tried to pickup an item that was not theirs!")
			end
		else
			self:Pickup(Player)
		end
	end)

    self.Model = model
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Service to Knit.
return item