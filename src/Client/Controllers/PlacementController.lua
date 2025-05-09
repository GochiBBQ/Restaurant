--[[
Author: alreadyfans
For: Gochi
]]

-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService: UserInputService = game:GetService("UserInputService")
local RunService: RunService = game:GetService("RunService")
local Players: Players = game:GetService("Players")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit) --- @module Knit

-- Variables
local Player: Player = Players.LocalPlayer
local Mouse: Mouse = Player:GetMouse()

local previewModel: Model = nil
local placing: boolean = false

local PlaceableModels: Folder = nil
local PlacementService: any = nil

-- Controller
local PlacementController = Knit.CreateController { Name = "PlacementController" }

-- Internal state
PlacementController.CurrentTool = nil
PlacementController.CurrentItemName = nil
PlacementController.CanPlace = false

-- Highlight preview parts
local function updateOutline(color)
	for _, part in previewModel:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 0.4
			part.Material = Enum.Material.ForceField
			part.Color = color
		end
	end
end

-- Set the tool/item to be placed
function PlacementController:SetCurrentItem(tool)
	self.CurrentTool = tool
	self.CurrentItemName = tool.Name
end

-- Start placement preview
function PlacementController:StartPlacement()
	if not self.CurrentItemName then
		warn("PlacementController: No item selected for placement.")
		return
	end

	print("[PlacementController] StartPlacement called for:", self.CurrentItemName)

	local template = PlaceableModels:FindFirstChild(self.CurrentItemName)
	if not template then
		warn("PlacementController: Item not found in PlaceableModels.")
		return
	end

	placing = true
	previewModel = template:Clone()
	previewModel.Parent = workspace

	-- Set PrimaryPart if not already set
	if not previewModel.PrimaryPart then
		local primary = previewModel:FindFirstChild("Table_Top") or previewModel:FindFirstChildWhichIsA("BasePart")
		if primary then
			previewModel.PrimaryPart = primary
		else
			warn("No suitable PrimaryPart found for previewModel.")
			return
		end
	end

	-- Apply preview properties to parts
	for _, part in pairs(previewModel:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 0.4
			part.Material = Enum.Material.ForceField
		end
	end

	-- Hide until positioned
	previewModel:SetPrimaryPartCFrame(CFrame.new(0, -100, 0))

	-- Update preview each frame
	RunService:BindToRenderStep("PlacementPreview", Enum.RenderPriority.Input.Value, function()
		if not placing or not previewModel then return end

		local target = Mouse.Hit
		if not target or not target.Position or target.Position.Magnitude > 1000 then
			self.CanPlace = false
			updateOutline(Color3.fromRGB(255, 0, 0))
			return
		end

		local primary = previewModel.PrimaryPart
		local height = primary and primary.Size.Y or 1

		local position = target.Position

		-- Always keep the preview upright & flat
		local flatCFrame = CFrame.new(Vector3.new(position.X, position.Y + height / 2, position.Z))
		previewModel:SetPrimaryPartCFrame(flatCFrame)

		-- Raycast check for valid placement
		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {workspace.Functionality.Tables}
		rayParams.FilterType = Enum.RaycastFilterType.Whitelist

		local result = workspace:Raycast(flatCFrame.Position + Vector3.new(0, 5, 0), Vector3.new(0, -10, 0), rayParams)
		if result and result.Instance and result.Instance:IsDescendantOf(workspace.Functionality.Tables) then
			self.CanPlace = true
			updateOutline(Color3.fromRGB(0, 255, 0)) -- Green
		else
			self.CanPlace = false
			updateOutline(Color3.fromRGB(255, 0, 0)) -- Red
		end
	end)

	-- Confirm placement on click
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and placing and self.CanPlace then
			self:ConfirmPlacement()
		end
	end)
end

-- Confirm placement and clean up
function PlacementController:ConfirmPlacement()
	placing = false
	RunService:UnbindFromRenderStep("PlacementPreview")

	local cframe = previewModel:GetPrimaryPartCFrame()
	PlacementService:RequestPlacement(self.CurrentItemName, cframe)

	previewModel:Destroy()
	previewModel = nil

	if self.CurrentTool then
		self.CurrentTool:Destroy()
	end

	self.CurrentTool = nil
	self.CurrentItemName = nil
	self.CanPlace = false
end

function PlacementController:KnitStart()
	PlacementService = Knit.GetService("PlacementService")

	PlaceableModels = Knit.Static:WaitForChild("PlaceableModels")
	if not PlaceableModels then
		error("PlacementController: PlaceableModels not found.")
	end
end

-- Return Controller
return PlacementController
