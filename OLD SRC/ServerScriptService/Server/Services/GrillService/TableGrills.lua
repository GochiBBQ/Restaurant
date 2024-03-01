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

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)
local TableGrills = {}
TableGrills.__index = TableGrills

-- ————————— ↢ ⭐️ ↣ —————————-
-- Server Functions
function TableGrills.new(tableGrill: Model)
    local self = setmetatable({}, TableGrills)

    self.Server = nil
    self.Customers = {}
    self.Grill = tableGrill

    self:Initialize(tableGrill)
    return self
end

function TableGrills:Initialize(tableGrill: Model)
    local TableService = Knit.GetService("GrillService")

    tableGrill.PromptHolder.ProximityPrompt.Triggered:Connect(function(Player)
        tableGrill.PromptHolder.ProximityPrompt.Enabled = false
        TableService.Client.Camera:Fire(Player, tableGrill)
    end)
end

    -- Tongs Animation (for after)
	--[[
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:FindFirstChild("Humanoid")
	local RightHand = Character:FindFirstChild("RightHand")
	local LeftHand = Character:FindFirstChild("LeftHand")

	local GrillingTongs = ReplicatedStorage:FindFirstChild("GrillingTongs"):Clone()
	local TongsHandle = ReplicatedStorage:FindFirstChild("TongsHandle"):Clone()

	task.wait(5)
	TongsHandle.Part0 = RightHand
	TongsHandle.Part1 = GrillingTongs
	TongsHandle.Parent = RightHand
	GrillingTongs.Parent = RightHand

	GrillingTongs["Raw Pork Belly"].Transparency = 0
	GrillingTongs.Transparency = 0

	local Animation = Humanoid:LoadAnimation(ReplicatedStorage.GrillingAnimation)
	Animation:Play()

	Animation.Ended:Connect(function()
		GrillingTongs.Transparency = 1
		GrillingTongs["Raw Pork Belly"].Transparency = 1
	end)
	--]]

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Module to Knit.
return TableGrills