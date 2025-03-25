--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit) --- @module Knit
local AnimNation = require(Knit.Modules.AnimNation) --- @module AnimNation
local Icon = require(Knit.Modules.Icon)
local Trove = require(ReplicatedStorage.Packages.Trove) --- @module Trove

-- Create Knit Controller
local UIController = Knit.CreateController {
	Name = "UIController",
	FrameOpen = false
}

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local UISelect = SoundService.UISelect
local UIHover = SoundService.UIHover

local ColorCorrection
local CurrentFrame = nil
local RankService
local HUDOpen = true

local Positions = {}
local trove = Trove.new()

-- Client Functions
local function FormatNumber(amount)
	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

function UIController:KnitStart()
	RankService = Knit.GetService("RankService")

	Icon.modifyBaseTheme(
		{"IconSpotGradient", "Color", ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("ff6f4b")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("ff4b97")),
		}), "Selected"},
		{"IconSpotGradient", "Rotation", 90, "Selected"}
	)

	self.UI = PlayerGui:WaitForChild("GochiUI")
	self.HUD = self.UI.HUD.Top

	self:AdvertisementBoards()
	self:InitHUD()

	local function UpdatePositions()
		for _, object in pairs(self.UI:GetDescendants()) do
			if object:IsA("GuiObject") and object.Position and not Positions[object] then
				Positions[object] = object.Position

				object.Destroying:Connect(function()
					Positions[object] = nil
				end)
			end
		end
	end

	UpdatePositions()

	trove:Connect(self.UI.DescendantAdded, function(descendant)
		if descendant:IsA("GuiObject") and descendant.Position then
			Positions[descendant] = descendant.Position

			descendant.Destroying:Connect(function()
				Positions[descendant] = nil
			end)
		end
	end)

	RankService:Get():andThen(function(Rank, Role)
		if Rank < 4 then
			self.HUD.Teams.Lock.Visible = true
		else
			self:InitGreetings()
			self:InitNotepad()
		end

		if Rank >= 7 then
			self:InitCommandBar()
		end
	end)

	ColorCorrection = Instance.new("ColorCorrectionEffect")
	ColorCorrection.Parent = Lighting
end

function UIController:InitGreetings()
	local icon = Icon.new()

	icon:setImage(17361522721)
	icon:autoDeselect(false)
	icon:setRight()

	self.UI["Greetings"].Main.Draggable = true

	local function hide()
		UISelect:Play()
		self:Close(self.UI["Greetings"], false)
	end

	local function show()
		UISelect:Play()
		self:Open(self.UI["Greetings"], false)
	end

	icon:bindEvent("selected", show)
	icon:bindEvent("deselected", hide)

	trove:Connect(self.UI["Greetings"].Main.Close.MouseButton1Down, function()
		icon:deselect()
		hide()
	end)
end

function UIController:InitNotepad()
	local icon = Icon.new()

	icon:setImage(17343409431)
	icon:autoDeselect(false)
	icon:setRight()

	self.UI["Notepad"].Draggable = true

	local function hide()
		UISelect:Play()
		self:Close(self.UI["Notepad"], false)
	end

	local function show()
		UISelect:Play()
		self:Open(self.UI["Notepad"], false)
	end

	icon:bindEvent("selected", show)
	icon:bindEvent("deselected", hide)

	trove:Connect(self.UI["Notepad"].Close.MouseButton1Down, function()
		icon:deselect()
		hide()
	end)
end

function UIController:InitCommandBar()
	local icon = Icon.new()
	icon:setImage(17875559779)
	icon:setName("Admin")

	trove:Connect(icon.selected, function()
		UISelect:Play()
		ReplicatedStorage.CmdBar:Fire()
		icon:deselect()
	end)
end

function UIController:HideHUD()
	AnimNation.target(self.HUD, {s = 10, d = 0.5}, {Position = UDim2.new(0.5, 0, -.1, 0)}):AndThen(function()
		self.HUD.Parent.CloseHUD.Visible = true
	end)
end

function UIController:ShowHUD()
	AnimNation.target(self.HUD, {s = 10, d = 0.5}, {Position = UDim2.new(0.5, 0, 0.032, 0)})
	self.HUD.Parent.CloseHUD.Visible = false
end

function UIController:Open(UI: GuiObject, Effects: boolean?)
	Effects = Effects == nil and true or Effects
	warn("Opening UI: " .. UI.Name)

	repeat task.wait() until not self.FrameOpen
	self.FrameOpen = true

	local Components = {}

	for _, object in pairs(UI:GetDescendants()) do
		if object:IsA("GuiObject") then
			object.Position = Positions[object]

			if object.Visible then
				table.insert(Components, {Frame = object, Visible = object.Visible, ClassName = object.ClassName, OriginalPosition = object.Position})
			end
		end
	end

	for _, component in pairs(Components) do
		local f = component.Frame
		if component.ClassName == "Frame" or component.ClassName == "ScrollingFrame" then
			f.Position -= UDim2.fromScale(0, 0.2)
			f.Visible = false
		elseif component.ClassName == "TextLabel" and f.Name == "Title" then
			f.Position = UDim2.fromScale(0.033, 0.03)
		elseif component.ClassName == "ImageButton" then
			f.Position = UDim2.fromScale(0.033, 0.03)
		elseif component.ClassName == "ImageLabel" and f.Name == "Background" then
			f.Position = UDim2.fromScale(0.5, 0.3)
			f.ImageTransparency = 1
		end
	end

	if Effects then
		if Lighting:FindFirstChild("Blur") then
			AnimNation.target(Lighting.Blur, {s = 3}, {Size = 35})
		end
		
		if workspace.CurrentCamera then
			AnimNation.target(workspace.CurrentCamera, {s = 3}, {FieldOfView = 90})
		end
		
		if ColorCorrection then
			AnimNation.target(ColorCorrection, {s = 3}, {TintColor = Color3.fromRGB(60, 60, 60)})
		end
	end

	UI.Visible = true

	for _, component in pairs(Components) do
		local f = component.Frame
		if f.Name == "Background" then
			AnimNation.target(f, {s = 10, d = 0.3}, {ImageTransparency = 0})
		end

		f.Visible = true
		AnimNation.target(f, {s = 10, d = 0.3}, {Position = component.OriginalPosition})
	end

	CurrentFrame = UI.Name
	Player:SetAttribute("UIOpen", true)
end

-- inside UIController:Close(UI: GuiObject, HUD: boolean?)

function UIController:Close(UI: GuiObject, HUD: boolean?)
    HUD = HUD == nil and true or HUD

    if not UI then return end

    local Components = {}

    for _, object in pairs(UI:GetDescendants()) do
        if object:IsA("GuiObject") and object.Visible then
            table.insert(Components, {Frame = object, Visible = object.Visible, ClassName = object.ClassName, OriginalPosition = object.Position})
        end
    end

    -- Close effects
	if Lighting:FindFirstChild("Blur") then
		AnimNation.target(Lighting.Blur, {s = 3}, {Size = 0})
	end
	
	if workspace.CurrentCamera then
		AnimNation.target(workspace.CurrentCamera, {s = 3}, {FieldOfView = 70})
	end
	
	if ColorCorrection then
		AnimNation.target(ColorCorrection, {s = 3}, {TintColor = Color3.fromRGB(255, 255, 255)})
	end
	

    for _, component in pairs(Components) do
        local f = component.Frame
        if component.ClassName == "Frame" or component.ClassName == "ScrollingFrame" then
            AnimNation.target(f, {s = 8, d = 0.2}, {Position = component.OriginalPosition + UDim2.fromScale(0, 0.2)})
        elseif component.ClassName == "TextLabel" and f.Name == "Title" then
            AnimNation.target(f, {s = 8, d = 0.2}, {Position = UDim2.fromScale(0.033, 0.03)})
        elseif component.ClassName == "ImageButton" then
            AnimNation.target(f, {s = 8, d = 0.2}, {Position = UDim2.fromScale(0.033, 0.03)})
        elseif component.ClassName == "ImageLabel" and f.Name == "Background" then
            AnimNation.target(f, {s = 10, d = 0.2}, {ImageTransparency = 1})
        end
    end

    UI.Visible = false

    for _, component in pairs(Components) do
        if component.Frame.Name == "Background" then
            AnimNation.target(component.Frame, {s = 10, d = 0.3}, {ImageTransparency = 1})
        end

        component.Frame.Visible = true
        AnimNation.target(component.Frame, {s = 10, d = 0.3}, {Position = component.OriginalPosition})
    end

    if HUD and CurrentFrame then
        local frame = self.HUD:FindFirstChild(CurrentFrame)
        if frame and frame:FindFirstChild("Background") then
            frame.Background.Image = "rbxassetid://136725729762264" -- Revert background gradient
        end  
    end

    CurrentFrame = nil
    self.FrameOpen = false
    Player:SetAttribute("UIOpen", false)
end


function UIController:InitHUD()
	trove:Connect(self.HUD.Parent.CloseHUD.Background.MouseButton1Down, function()
		self:ShowHUD()
		HUDOpen = true
	end)

	for _, frame in pairs(self.HUD:GetChildren()) do
		if frame:IsA("Frame") then
			local originalSize = frame.Size

			trove:Connect(frame.Background.MouseEnter, function()
				AnimNation.target(frame, {s = 10, d = 1}, {Size = originalSize + UDim2.fromOffset(10, 10)})
				UIHover:Play()
			end)

			trove:Connect(frame.Background.MouseLeave, function()
				AnimNation.target(frame, {s = 10, d = 1}, {Size = originalSize})
			end)

			trove:Connect(frame.Background.MouseButton1Down, function()
				if frame.Name == "CloseHUD" then
					if HUDOpen then self:HideHUD() HUDOpen = false end
					return
				end

				if CurrentFrame == frame.Name then
					self:Close(self.UI[CurrentFrame])
					return
				elseif CurrentFrame and CurrentFrame ~= frame.Name then
					local OpenFrame = self.HUD[CurrentFrame]
					if OpenFrame then
						OpenFrame.Background.Image = "rbxassetid://136725729762264"
						self:Close(self.UI[CurrentFrame])
					end
				end

				if frame:FindFirstChild("Lock") and frame.Lock.Visible then return end

				UISelect:Play()
				frame.Background.Image = "rbxassetid://131104397343477"
				CurrentFrame = frame.Name
				self:Open(self.UI[frame.Name])
			end)

			if frame.Name ~= "CloseHUD" and self.UI[frame.Name]:FindFirstChild("Close") then
				trove:Connect(self.UI[frame.Name].Close.MouseButton1Down, function()
					self:Close(self.UI[frame.Name])
				end)
			end
		end
	end
end

function UIController:AdvertisementBoards()
	local AdvertBoards = workspace.Functionality.Advertisements
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Distance = 15

	local lastUpdate = 0
	local updateInterval = 0.3 -- every 0.3 seconds

trove:Connect(RunService.RenderStepped, function(dt)
	lastUpdate += dt
	if lastUpdate < updateInterval then return end
	lastUpdate = 0

	local root = Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	for _, AdvertBoard in pairs(AdvertBoards:GetChildren()) do
		local Surface = AdvertBoard:FindFirstChild("SurfaceDisplay")
		local Frame = Surface and Surface:FindFirstChild("SurfaceGui") and Surface.SurfaceGui.Frame.Frame
		if Surface and Frame then
			local magnitude = (root.Position - Surface.Position).Magnitude
			local pos = magnitude < Distance and UDim2.fromScale(0, 0) or UDim2.fromScale(0, 1)
			AnimNation.target(Frame, {s = 5, d = 0.9}, {Position = pos})
		end
	end
end)

end

-- Return Controller to Knit.
return UIController
