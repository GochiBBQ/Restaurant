--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService = game:GetService('UserInputService')
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService('StarterGui')
local Players = game:GetService('Players')

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local ViewportManager = require(Knit.Modules.ViewportManager)
local spr = require(Knit.Modules.spr)
local AnimNation = require(Knit.Modules.AnimNation)
local Trove = require(ReplicatedStorage.Packages.Trove) --- @module Trove

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local UISelect = SoundService.UISelect
local UIHover = SoundService.UIHover

local assignedNumbers = {}
local toolToNumber = {}

-- Create Knit Controller
local BackpackController = Knit.CreateController {
    Name = "BackpackController",
    InputKeys = {
        [1] = "One",
        [2] = "Two",
        [3] = "Three",
        [4] = "Four",
        [5] = "Five",
        [6] = "Six",
        [7] = "Seven",
        [8] = "Eight",
        [9] = "Nine",
        [0] = "Zero",
    },
}

BackpackController._trove = Trove.new()
BackpackController._uiTrove = Trove.new()
BackpackController._characterTrove = Trove.new()

-- Client Functions

-- Equips the specified tool to the player's character.
function BackpackController:EquipItem(Tool)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:FindFirstChild("Humanoid")

    if Tool and Humanoid and Tool.Parent ~= Character then
        Humanoid:EquipTool(Tool)
    end
end

-- Unequips the currently equipped item from the player's character.
function BackpackController:UnequipItem()
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:FindFirstChild("Humanoid")

    if Humanoid then
        Humanoid:UnequipTools()
    end
end

-- Handles the key press event for the backpack controller.
function BackpackController:OnKeyPress(Input)
    local KeyBind = Input.KeyCode.Name
    local number = false

    for key, value in pairs(self.InputKeys) do
        if value == KeyBind then
            KeyBind = key
            number = true
        end
    end

    if KeyBind and number and not UserInputService:GetFocusedTextBox() then
        local Frame = PlayerGui:WaitForChild("Backpack").Frame[KeyBind]
        local ImageButton = Frame:FindFirstChildOfClass("ImageButton")

        if ImageButton then self:RegisterButtonClick(ImageButton) end
    end
end

-- Handles the button click event for the backpack UI.
function BackpackController:RegisterButtonClick(Button)
    if self.ActiveTool then
        local OldButton = PlayerGui:WaitForChild("Backpack").Frame[self.ActiveTool]:FindFirstChildOfClass("ImageButton")
        if OldButton then
            OldButton.Parent.UIGradient.Enabled = false
            OldButton.Parent.UIStroke.UIGradient.Enabled = false
            AnimNation.target(OldButton.Parent, {s = 8, d = 0.8}, { BackgroundTransparency = 0.75 })
            AnimNation.target(OldButton.Parent, {s = 8, d = 0.8}, { Size = UDim2.fromScale(0.35, 1) })
            self:UnequipItem()
        end
    end

    if self.ActiveTool ~= Button.Parent.Name then
        UISelect:Play()
        Button.Parent.UIGradient.Enabled = true
        Button.Parent.UIStroke.UIGradient.Enabled = true
        AnimNation.target(Button.Parent, {s = 8, d = 0.8}, { BackgroundTransparency = 0.3 })
        AnimNation.target(Button.Parent, {s = 8, d = 0.8}, { Size = UDim2.fromScale(0.7, 1.3) })
        self:EquipItem(Player.Backpack:FindFirstChild(Button.Name))
        self.ActiveTool = Button.Parent.Name
    else
        Button.Parent.UIGradient.Enabled = false
        Button.Parent.UIStroke.UIGradient.Enabled = false
        AnimNation.target(Button.Parent, {s = 8, d = 0.8}, { BackgroundTransparency = 0.75 })
        AnimNation.target(Button.Parent, {s = 8, d = 0.8}, { Size = UDim2.fromScale(0.35, 1) })
        self:UnequipItem()
        self.ActiveTool = nil
    end
end

-- Assigns a number to the given tool if it hasn't been assigned already.
function BackpackController:AssignNumberToTool(Tool)
    if toolToNumber[Tool] then return end

    for i = 0, 9 do
        if not assignedNumbers[i] then
            assignedNumbers[i] = Tool
            toolToNumber[Tool] = i
            self:UpdateUIButton(Tool, i)
            return
        end
    end
end

-- Removes the number associated with a given tool from the tool-to-number mapping.
function BackpackController:RemoveNumberFromTool(Tool)
    local number = toolToNumber[Tool]
    if number then
        assignedNumbers[number] = nil
        toolToNumber[Tool] = nil
        self:ClearUIButton(number, Tool)
    end
end

-- Updates the UI button in the backpack with the given tool and number.
function BackpackController:UpdateUIButton(Tool, number)
    local Button = PlayerGui:WaitForChild("Backpack").Frame[tostring(number)]:FindFirstChildOfClass("ImageButton")
    if Button then
        Button.Name = Tool.Name

        local ViewportFrame = Button.Parent.ViewportFrame
        local Camera = Instance.new("Camera")
        Camera.Parent = ViewportFrame
        Camera.FieldOfView = -50
        self._characterTrove:Add(Camera)

        local ViewportModel = Knit.Static.ViewportModels:FindFirstChild(Tool.Name):Clone()
        ViewportModel.Parent = ViewportFrame
        ViewportFrame.CurrentCamera = Camera
        self._characterTrove:Add(ViewportModel)

        local PlayerViewport = ViewportManager.new(ViewportFrame, Camera)
        PlayerViewport:Calibrate()

        local CF, Size = ViewportModel:GetBoundingBox()
        PlayerViewport:SetModel(ViewportModel)
        Camera.CFrame = PlayerViewport:GetMinimumFitCFrame(CFrame.new()) * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(15))
    end
end

-- Clears the UI button in the backpack interface.
function BackpackController:ClearUIButton(number, Tool)
    local Button = PlayerGui:WaitForChild("Backpack").Frame[tostring(number)]:FindFirstChildOfClass("ImageButton")
    if Button then
        Button.Name = ""
        if Tool then
            local Model = Button.Parent.ViewportFrame:FindFirstChild(Tool.Name)
            if Model then Model:Destroy() end
        end
        local Camera = Button.Parent.ViewportFrame:FindFirstChildOfClass("Camera")
        if Camera then Camera:Destroy() end
    end
end

-- Handles the event when a tool is added to the backpack.
function BackpackController:OnToolAdded(Tool)
    self:AssignNumberToTool(Tool)
end

-- Handles the removal of a tool from the player's backpack.
function BackpackController:OnToolRemoved(Tool)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    if not Character:FindFirstChild(Tool.Name) then
        self:RemoveNumberFromTool(Tool)
    end
end

-- Clears the inventory.
function BackpackController:ClearInventory()
    for i = 0, 9 do
        local Tool
        for number, tool in pairs(toolToNumber) do
            if i == number then
                Tool = tool
                break
            end
        end
        self:ClearUIButton(i, Tool)
        assignedNumbers[i] = nil
    end
    toolToNumber = {}
end

-- Updates the UI for the backpack.
function BackpackController:UpdateUI()
    for number, tool in pairs(assignedNumbers) do
        self:UpdateUIButton(tool, number)
    end
end

-- Initializes the backpack UI.
function BackpackController:InitializeBackpackUI()
    self._uiTrove:Clean()

    for _, Button in pairs(PlayerGui:WaitForChild("Backpack").Frame:GetDescendants()) do
        if Button:IsA("ImageButton") then
            local enterConn = Button.MouseEnter:Connect(function()
                UIHover:Play()
                AnimNation.target(Button.Parent, {s = 8, d = 0.8}, { Size = UDim2.fromScale(0.7, 1.3) })
            end)

            local leaveConn = Button.MouseLeave:Connect(function()
                if self.ActiveTool ~= Button.Parent.Name then
                    AnimNation.target(Button.Parent, {s = 8, d = 0.8}, { Size = UDim2.fromScale(0.35, 1) })
                end
            end)

            local clickConn = Button.MouseButton1Down:Connect(function()
                self:RegisterButtonClick(Button)
            end)

            self._uiTrove:Add(enterConn)
            self._uiTrove:Add(leaveConn)
            self._uiTrove:Add(clickConn)
        end
    end
end

-- Resets the connections for the player's backpack.
function BackpackController:ResetConnections()
    self._characterTrove:Clean()

    local addedConn = Player.Backpack.ChildAdded:Connect(function(Tool)
        self:OnToolAdded(Tool)
    end)
    local removedConn = Player.Backpack.ChildRemoved:Connect(function(Tool)
        self:OnToolRemoved(Tool)
    end)
    local inputConn = UserInputService.InputBegan:Connect(function(Input)
        self:OnKeyPress(Input)
    end)

    self._characterTrove:Add(addedConn)
    self._characterTrove:Add(removedConn)
    self._characterTrove:Add(inputConn)
end

-- Initializes the BackpackController when Knit starts.
function BackpackController:KnitStart()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

    self:InitializeBackpackUI()
    self:ClearInventory()
    self:ResetConnections()

    for _, Tool in pairs(Player.Backpack:GetChildren()) do
        self:OnToolAdded(Tool)
    end

    local charConn = Player.CharacterAdded:Connect(function()
        self._characterTrove:Clean()
        self._uiTrove:Clean()

        self:InitializeBackpackUI()
        self:ClearInventory()
        self:ResetConnections()

        for _, Tool in pairs(Player.Backpack:GetChildren()) do
            self:OnToolAdded(Tool)
        end
    end)

    self._trove:Add(charConn)
end

-- Return controller to Knit
return BackpackController
