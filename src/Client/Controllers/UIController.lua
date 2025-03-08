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
local Knit = require(ReplicatedStorage.Packages.Knit)
local UIEffects = require(Knit.Modules.UIEffects)
local AnimNation = require(Knit.Modules.AnimNation) --- @module AnimNation
local spr = require(Knit.Modules.spr)
local Icon = require(Knit.Modules.Icon)

-- Variables

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local UISelect = SoundService.UISelect
local UIHover = SoundService.UIHover

local ColorCorrection
local CurrentFrame = nil
local FrameOpen = false
local RankService

local HUDOpen = true

local Positions = {}

-- Create Knit Controller
local UIController = Knit.CreateController {
    Name = "UIController",
}

-- Client Functions

--[[
    Formats a number by adding commas as thousand separators.
    This function takes a numerical value as input and returns a string with commas inserted at every thousand place.

    @function FormatNumber
    @param amount number -- The numerical value to be formatted.
    @return string -- The formatted number as a string.
    @within UIController
]]
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

--[[
    Initializes the UIController when the Knit framework starts.
    Retrieves the RankService from Knit, modifies the base theme of the Icon, waits for the "GochiUI" GUI to be available in the PlayerGui, initializes the HUD and advertisement boards, stores the initial positions of all GUI objects in the Positions table, and retrieves the player's rank and role from the RankService.

    If the rank is less than 4, shows the lock on the HUD teams.
    If the rank is 4 or higher, initializes the greetings and notepad.
    If the rank is 7 or higher, initializes the command bar.

    @function InitUIController
    @within UIController
]]
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

	for _, object in pairs(self.UI:GetDescendants()) do
		if object:IsA("GuiObject") then
			Positions[object] = object.Position
		end
	end

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

--[[
    Initializes the greetings UI component.
    Sets up the greetings UI by creating a new icon, configuring its image, and setting up event bindings for showing and hiding the greetings UI.
    Makes the greetings UI draggable and connects the close button to hide the UI.

    @function InitGreetingsUI
    @within UIController
]]
function UIController:InitGreetings()
    local icon = Icon.new()

    icon:setImage(17361522721)
	icon:autoDeselect(false)

    self.UI["Greetings"].Main.Draggable = true
    
    local function hide()
        UISelect:Play()
        self:Close(self.UI["Greetings"], false)
    end

    local function show()
        UISelect:Play()
        self:Open(self.UI["Greetings"], false)
    end

    icon:bindEvent('selected', show)
    icon:bindEvent('deselected', hide)

    self.UI["Greetings"].Main.Close.MouseButton1Down:Connect(function()
        icon:deselect()
        hide()
    end)
end

--[[
    Initializes the Notepad UI component.
    
    This function sets up the Notepad UI with the following features:
    - Creates a new icon and sets its image.
    - Configures the icon to not auto-deselect.
    - Makes the Notepad UI draggable.
    - Defines and binds the show and hide functions to the icon's selected and deselected events.
    - Connects the Notepad's close button to hide the Notepad and deselect the icon when clicked.

    @function InitNotepad
    @within UIController
]]
function UIController:InitNotepad()
    local icon = Icon.new()

    icon:setImage(17343409431)
	icon:autoDeselect(false)

    self.UI["Notepad"].Draggable = true
    
    local function hide()
        UISelect:Play()
        self:Close(self.UI["Notepad"], false)
    end

    local function show()
        UISelect:Play()
        self:Open(self.UI["Notepad"], false)
    end

    icon:bindEvent('selected', show)
    icon:bindEvent('deselected', hide)

    self.UI["Notepad"].Close.MouseButton1Down:Connect(function()
        icon:deselect()
        hide()
    end)
end

--[[
    Initializes the command bar UI element.
    Creates a new icon, sets its image and name, and connects the icon's selected event to a function that plays a UI selection sound, fires a command bar event, and deselects the icon.

    @function InitCommandBar
    @within UIController
]]
function UIController:InitCommandBar()
    local icon = Icon.new()

    :setImage(17875559779)
    :setName("Admin")

    icon.selected:Connect(function()
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

--[[
    Opens a UI element with optional effects.
    This function waits until no other frame is open, then opens the specified UI element.
    It optionally applies visual effects to the UI components and the environment.
]]
function UIController:Open(UI: GuiObject, Effects: boolean?)

    if Effects == nil then
        Effects = true
    end

    repeat task.wait() until not FrameOpen

    FrameOpen = true

    local Components = {}

    if UI then
        for _, object in pairs(UI:GetDescendants()) do
            if object:IsA("GuiObject") then
                object.Position = Positions[object]

                if object.Visible then
                    table.insert(Components, {Frame = object, Visible = object.Visible, ClassName = object.ClassName, OriginalPosition = object.Position})
                end
            end
        end

        for _, component in pairs(Components) do
            if component.ClassName == "Frame" or component.ClassName == "ScrollingFrame" then
                component.Frame.Position -= UDim2.fromScale(0, 0.2)
                component.Frame.Visible = false
            elseif component.ClassName == "TextLabel" then
                if component.Frame.Name == "Title" then
                    component.Frame.Position = UDim2.fromScale(0.033, 0.03)
                end
            elseif component.ClassName == "ImageButton" then
                component.Frame.Position = UDim2.fromScale(0.033, 0.03)
            elseif component.ClassName == "ImageLabel" then
                if component.Frame.Name == "Background" then
                    component.Frame.Position = UDim2.fromScale(0.5, 0.3)
                    component.Frame.ImageTransparency = 1
                end
            end
        end

        if Effects then
            AnimNation.target(Lighting.Blur, {s = 3}, {Size = 35})
            AnimNation.target(workspace.CurrentCamera, {s = 3}, {FieldOfView = 90})
            AnimNation.target(ColorCorrection, {s = 3}, {TintColor = Color3.fromRGB(60, 60, 60)})
        end

        UI.Visible = true

        for _, component in pairs(Components) do
            if component.Frame.Name == "Background" then
                AnimNation.target(component.Frame, {s = 10, d = 0.3}, {ImageTransparency = 0})
            end

            component.Frame.Visible = true
            AnimNation.target(component.Frame, {s = 10, d = 0.3}, {Position = component.OriginalPosition})
        end

        CurrentFrame = UI.Name

        Player:SetAttribute("UIOpen", true)
    end
end

--[[
    Closes the specified UI element with optional HUD handling.
    This function animates the closing of the UI element by targeting its components and applying specific animations based on their class names.
    It also handles the visibility of the UI and resets the positions of the components after the animations are completed.
    If HUD is enabled, it updates the HUD frame's background image.

    @function Close
    @param UI GuiObject -- The UI element to be closed.
    @param HUD boolean? -- Optional parameter to determine if HUD handling is required. Defaults to true.
    @within UIController
]]
function UIController:Close(UI: GuiObject, HUD: boolean?)

    if HUD == nil then
        HUD = true
    end

    if UI then
        local Components = {}

        for _, object in pairs(UI:GetDescendants()) do
            if object:IsA("GuiObject") and object.Visible then
                table.insert(Components, {Frame = object, Visible = object.Visible, ClassName = object.ClassName, OriginalPosition = object.Position})
            end
        end
        
        AnimNation.target(Lighting.Blur, {s = 3}, {Size = 0})
        AnimNation.target(workspace.CurrentCamera, {s = 3}, {FieldOfView = 70})
        AnimNation.target(ColorCorrection, {s = 3}, {TintColor = Color3.fromRGB(255, 255, 255)})

        for _, component in pairs(Components) do
            if component.ClassName == "Frame" or component.ClassName == "ScrollingFrame" then
                AnimNation.target(component.Frame, {s = 8, d = 0.2}, {Position = component.OriginalPosition + UDim2.fromScale(0, 0.2)})
            elseif component.ClassName == "TextLabel" then
                if component.Frame.Name == "Title" then
                    AnimNation.target(component.Frame, {s = 8, d = 0.2}, {Position = UDim2.fromScale(0.033, 0.03)})
                end
            elseif component.ClassName == "ImageButton" then
                AnimNation.target(component.Frame, {s = 8, d = 0.2}, {Position = UDim2.fromScale(0.033, 0.03)})
            elseif component.ClassName == "ImageLabel" then
                if component.Frame.Name == "Background" then
                    AnimNation.target(component.Frame, {s = 10, d = 0.2}, {ImageTransparency = 1})
                end
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
                frame.Background.Image = "rbxassetid://136725729762264"
            end  
        end

        CurrentFrame = nil
        FrameOpen = false

        Player:SetAttribute("UIOpen", false)
    end
end


--[[
    Initializes the HUD UI elements.
    Iterates through the children of the HUD, setting up mouse enter, leave, and click events for each frame.
    Handles frame resizing on hover, frame selection, and frame closing.

    @function InitHUD
    @within UIController
]]
function UIController:InitHUD()

    self.HUD.Parent.CloseHUD.Background.MouseButton1Down:Connect(function()
        self:ShowHUD()
        HUDOpen = true
    end)

    for _, frame in pairs(self.HUD:GetChildren()) do
        if frame:IsA("Frame") then
            local originalSize = frame.Size

            frame.Background.MouseEnter:Connect(function()
                -- spr.target(frame, 1, 3, {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 10, originalSize.Y.Scale, originalSize.Y.Offset + 10)})
                AnimNation.target(frame, {s = 10, d = 1}, {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 10, originalSize.Y.Scale, originalSize.Y.Offset + 10)})
                UIHover:Play()
            end)

            frame.Background.MouseLeave:Connect(function()
                -- spr.target(frame, 1, 3, {Size = originalSize})
                AnimNation.target(frame, {s = 10, d = 1}, {Size = originalSize})
            end)

            frame.Background.MouseButton1Down:Connect(function()

                if frame.Name == "CloseHUD" then
                    if HUDOpen then
                        self:HideHUD()
                        HUDOpen = false
                    end
                    return
                end

                if CurrentFrame and CurrentFrame == frame.Name then
                    self:Close(self.UI[CurrentFrame])
                    return
                elseif CurrentFrame and CurrentFrame ~= frame.Name then
                    local OpenFrame = self.HUD[CurrentFrame]
                    if OpenFrame then
                    	OpenFrame.Background.Image = "rbxassetid://136725729762264"
                        self:Close(self.UI[CurrentFrame])
                    end
                end

                if frame:FindFirstChild("Lock") then
                    if frame.Lock.Visible then
                        return
                    end
                end

                UISelect:Play()
                frame.Background.Image = "rbxassetid://131104397343477"

                CurrentFrame = frame.Name
                local UI = self.UI[frame.Name]

                if UI then
                    self:Open(UI)
                end
            end)

			if frame.Name ~= "CloseHUD" and self.UI[frame.Name]:FindFirstChild("Close") then
				self.UI[frame.Name].Close.MouseButton1Down:Connect(function()
					self:Close(self.UI[frame.Name])
				end)
			end
        end
    end
end

--[[
    Handles the advertisement boards UI.
    Checks the distance between the player's character and advertisement boards in the workspace.
    If the character is within a specified distance, it animates the advertisement board's frame to be visible.
    Otherwise, it hides the frame.

    @function AdvertisementBoards
    @within UIController
]]
function UIController:AdvertisementBoards()
	local AdvertBoards = workspace.Functionality.Advertisements
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Distance = 15

	local function CheckDistance()
		for i, AdvertBoard in pairs(AdvertBoards:GetChildren()) do
			local Humanoid = Character:WaitForChild("HumanoidRootPart")
			local Surface = AdvertBoard:WaitForChild("SurfaceDisplay")
			local Frame = Surface.SurfaceGui.Frame.Frame
	
			if Humanoid then
				local Magnitude = Player:DistanceFromCharacter(AdvertBoard.SurfaceDisplay.Position)
				if Magnitude < Distance then
					-- spr.target(Frame, 0.9, 2, { Position = UDim2.fromScale(0, 0)})
                    AnimNation.target(Frame, {s = 5, d = 0.9}, {Position = UDim2.fromScale(0, 0)})
				else
					-- spr.target(Frame, 0.9, 2, { Position = UDim2.fromScale(0, 1)})
                    AnimNation.target(Frame, {s = 5, d = 0.9}, {Position = UDim2.fromScale(0, 1)})
				end
			end
		end
	end

	RunService.RenderStepped:Connect(function()
		CheckDistance()
	end)
end

 -- Return Controller to Knit.
return UIController
