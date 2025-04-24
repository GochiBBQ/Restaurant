--[[
Author: alreadyfans
For: Gochi
]]

-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local TableMap = require(ServerScriptService.Structures.TableMap) -- @module TableMap

-- Variables
local Animations = ServerStorage:WaitForChild("Animations")

-- Create Service
local AnimationService = Knit.CreateService {
    Name = "AnimationService",
    Client = {},
}

-- Private State
local ongoingAnimations = TableMap.new()           -- Player -> AnimationTrack
local ongoingModelAnimations = TableMap.new()      -- Player -> Model's AnimationTrack

-- Utility: Load and return AnimationTrack
local function loadAnimation(Character: Instance, Animation: Animation)
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then return end

	local Animator = Humanoid:FindFirstChildOfClass("Animator")
	if not Animator then return end

	return Animator:LoadAnimation(Animation)
end

-- Utility: Lock or unlock a player to a model
local function lockPlayer(Player: Player, Model: Model, State: boolean)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local HRP = Character:FindFirstChild("HumanoidRootPart")
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local ModelRoot = Model:FindFirstChild("HumanoidRootPart")

	if not HRP or not Humanoid or not ModelRoot then return end

	if State then
		Humanoid.WalkSpeed = 0
		Humanoid.JumpPower = 0
		Humanoid.PlatformStand = true
		HRP.Anchored = true
		HRP.CFrame = ModelRoot.CFrame
	else
		Humanoid.PlatformStand = false
		HRP.Anchored = false
		Humanoid.WalkSpeed = (Player:GetAttribute("Walkspeed") and 32) or 16
		Humanoid.JumpPower = 50
	end
end

function AnimationService:_playAnimation(Player: Player, Animation: Animation, AttachToModel: Model?, Looped: boolean?)
	if Looped == nil then
		Looped = false
	end

	local Character = Player.Character or Player.CharacterAdded:Wait()
	self:_stopAnimation(Player)

	-- Load animation for the player
	local playerTrack = loadAnimation(Character, Animation)
	if not playerTrack then
		warn("Failed to load animation for player:", Animation.Name)
		return
	end

	playerTrack.Looped = Looped or false
	playerTrack.Priority = Enum.AnimationPriority.Action4
	playerTrack:Play()

	ongoingAnimations:set(Player, playerTrack)
	Player:SetAttribute("AnimationLength", playerTrack.Length)

	local modelTrack

	if AttachToModel then
		AttachToModel:SetAttribute("InUse", true)
		lockPlayer(Player, AttachToModel, true)

		-- Try to load animation on the model if it has an AnimationController
		local controller = AttachToModel:FindFirstChildOfClass("AnimationController")
		if not controller then
			controller = Instance.new("AnimationController")
			controller.Name = "AnimationController"
			controller.Parent = AttachToModel
		end

		local ok, result = pcall(function()
			return controller:LoadAnimation(Animation)
		end)
		if ok and result then
			modelTrack = result
			modelTrack.Looped = Looped or false
			modelTrack.Priority = Enum.AnimationPriority.Action4
			modelTrack:Play()
			ongoingModelAnimations:set(Player, modelTrack)
		else
			warn("Failed to load animation on model:", AttachToModel.Name)
		end
	end

	playerTrack.Stopped:Connect(function()
		if AttachToModel then
			AttachToModel:SetAttribute("InUse", false)
			lockPlayer(Player, AttachToModel, false)

			if modelTrack then
				modelTrack:Stop()
				ongoingModelAnimations:remove(Player)
			end
		end
		ongoingAnimations:remove(Player)
		Player:SetAttribute("AnimationLength", nil)
	end)
end

function AnimationService:_stopAnimation(Player: Player)
	local Character = Player.Character
	if Character then
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			local Animator = Humanoid:FindFirstChildOfClass("Animator")
			if Animator then
				for _, track in ipairs(Animator:GetPlayingAnimationTracks()) do
					track:Stop()
				end
			end
		end
	end

	local playerTrack = ongoingAnimations:get(Player)
	if playerTrack then
		playerTrack:Stop()
		ongoingAnimations:remove(Player)
		Player:SetAttribute("AnimationLength", nil)
	end

	local modelTrack = ongoingModelAnimations:get(Player)
	if modelTrack then
		modelTrack:Stop()
		ongoingModelAnimations:remove(Player)
	end
end

-- Cleanup on player leave
function AnimationService:KnitStart()
	Players.PlayerRemoving:Connect(function(player)
		self:_stopAnimation(player)
	end)
end

-- Client Functions
function AnimationService.Client:PlayAnimation(Player: Player, FolderName: string, AnimationName: string, AttachToModel: Model?, Looped: boolean?)
	local AnimationFolder = Animations:FindFirstChild(FolderName)
	if not AnimationFolder then
		warn("Animation folder not found:", FolderName)
		return
	end

	local Animation = AnimationFolder:FindFirstChild(AnimationName)
	if not Animation then
		warn("Animation not found:", AnimationName)
		return
	end

	self.Server:_playAnimation(Player, Animation, AttachToModel, Looped)
end

function AnimationService.Client:StopAnimation(Player: Player)
	self.Server:_stopAnimation(Player)
end

return AnimationService
