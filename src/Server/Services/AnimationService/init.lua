--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local TableMap = require(Knit.Structures.TableMap) -- @module TableMap

-- Variables
local Animations = ServerStorage:WaitForChild("Animations")

-- Create Service
local AnimationService = Knit.CreateService {
    Name = "AnimationService",
    Client = {},
}

-- Private State
local ongoingAnimations = TableMap.new()

-- Utility: Load and return AnimationTrack
local function LoadAnimation(Character: Instance, Animation: Animation)
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then return end

	local Animator = Humanoid:FindFirstChildOfClass("Animator")
	if not Animator then return end

	return Animator:LoadAnimation(Animation)
end

-- Utility: Lock or unlock a player to a model
local function LockPlayerToModel(Player: Player, Model: Model, State: boolean)
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

-- Public: Play animation with optional lock
function AnimationService:_playAnimation(Player: Player, Animation: Animation, AttachToModel: Model?)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	self:_stopAnimation(Player) -- Stop any ongoing animation

	-- Load animation for player
	local track = LoadAnimation(Character, Animation)
	if not track then
		warn("Failed to load animation for player:", Animation.Name)
		return
	end
	print("Loaded animation:", Animation.Name)

	ongoingAnimations:set(Player, track)

	if AttachToModel then
		AttachToModel:SetAttribute("InUse", true)
		LockPlayerToModel(Player, AttachToModel, true)
	end

    track.Priority = Enum.AnimationPriority.Action4
	track:Play()

	track.Stopped:Connect(function()
		if AttachToModel then
			AttachToModel:SetAttribute("InUse", false)
			LockPlayerToModel(Player, AttachToModel, false)
		end
		ongoingAnimations:remove(Player)
	end)
end


function AnimationService:_stopAnimation(Player: Player)
    local currentTrack = ongoingAnimations:get(Player)
    if currentTrack then
        currentTrack:Stop()
        ongoingAnimations:remove(Player)
    end
    
end

-- Cleanup on player leave
function AnimationService:KnitStart()
	Players.PlayerRemoving:Connect(function(player)
		local current = ongoingAnimations:get(player)
		if current then
			current:Stop()
			ongoingAnimations:remove(player)
		end
	end)
end

-- Client Functions
function AnimationService.Client:PlayAnimation(Player: Player, FolderName: string, AnimationName: string, AttachToModel: Model?)
    local Animation = Animations:FindFirstChild(FolderName):FindFirstChild(AnimationName)
    if not Animation then
        warn("Animation not found:", AnimationName)
        return
    end
    self.Server:_playAnimation(Player, Animation, AttachToModel)    
end

function AnimationService.Client:StopAnimation(Player: Player)
    self.Server:_stopAnimation(Player)
end

return AnimationService
