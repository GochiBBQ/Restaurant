--[[

Author: alreadyfans
For: Gochi

]]

-- ————————— 🂡 —————————
-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService = game:GetService('UserInputService')
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService('StarterGui')
local Players = game:GetService('Players')

-- ————————— 🂡 —————————
-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local ViewportManager = require(Knit.Modules.ViewportManager)
local spr = require(Knit.Modules.spr)

-- ————————— 🂡 —————————
-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local UISelect = SoundService.UISelect
local UIHover = SoundService.UIHover

local assignedNumbers = {}
local toolToNumber = {}

-- ————————— 🂡 —————————
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

-- ————————— 🂡 —————————
-- Client Functions
--[[
    Equips the specified tool to the player's character.
    Waits for the player's character to be available if not already present.
    Finds the humanoid component of the character and equips the tool if it is not already equipped.

    @function EquipItem
    @param Tool The tool instance to be equipped.
    @within BackpackController
]]
function BackpackController:EquipItem(Tool)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:FindFirstChild("Humanoid")

    if Tool and Humanoid and Tool.Parent ~= Character then
        Humanoid:EquipTool(Tool)
    end
end

--[[
    Unequips the currently equipped item from the player's character.
    Waits for the player's character to be added if it doesn't exist, then finds the humanoid component and unequips any tools the humanoid is holding.

    @function UnequipItem
    @within BackpackController
]]
function BackpackController:UnequipItem()
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:FindFirstChild("Humanoid")

    if Humanoid then
        Humanoid:UnequipTools()
    end
end

--[[
    Handles the key press event for the backpack controller.
    Checks if the pressed key matches any key in the input keys, and if so, triggers the corresponding button click in the backpack UI.

    @function OnKeyPress
    @param Input The input object containing information about the key press event.
    @within BackpackController
]]
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

--[[
    Handles the button click event for the backpack UI.
    Deselects the previously selected item, if any, and selects the new item.
    If the same item is clicked again, it deselects the item.

    @function RegisterButtonClick
    @param Button The button that was clicked.
    @within BackpackController
]]
function BackpackController:RegisterButtonClick(Button)
    -- Deselect previously selected item
    if self.ActiveTool then
        local OldButton = PlayerGui:WaitForChild("Backpack").Frame[self.ActiveTool]:FindFirstChildOfClass("ImageButton")
        if OldButton then
            OldButton.Parent.UIGradient.Enabled = false
            OldButton.Parent.UIStroke.UIGradient.Enabled = false
            spr.target(OldButton.Parent, 0.8, 4, { BackgroundTransparency = 0.75 })
            spr.target(OldButton.Parent, 0.8, 4, { Size = UDim2.fromScale(0.35, 1) })
            self:UnequipItem()
        end
    end

    -- Select the new item
    if self.ActiveTool ~= Button.Parent.Name then
        UISelect:Play()
        Button.Parent.UIGradient.Enabled = true
        Button.Parent.UIStroke.UIGradient.Enabled = true
        spr.target(Button.Parent, 0.8, 4, { BackgroundTransparency = 0.3 })
        spr.target(Button.Parent, 0.8, 4, { Size = UDim2.fromScale(0.7, 1.3) })
        self:EquipItem(Player.Backpack:FindFirstChild(Button.Name))
        self.ActiveTool = Button.Parent.Name
    else
        -- If the same item is clicked again, deselect it
        Button.Parent.UIGradient.Enabled = false
        Button.Parent.UIStroke.UIGradient.Enabled = false
        spr.target(Button.Parent, 0.8, 4, { BackgroundTransparency = 0.75 })
        spr.target(Button.Parent, 0.8, 4, { Size = UDim2.fromScale(0.35, 1) })
        self:UnequipItem()
        self.ActiveTool = nil
    end
end

--[[
    Assigns a number to the given tool if it hasn't been assigned already.
    Iterates through numbers 0 to 9 and assigns the first available number to the tool.
    Updates the UI button with the assigned number.

    @function AssignNumberToTool
    @param Tool The tool to which a number will be assigned.
    @within BackpackController
]]
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

--[[
    Removes the number associated with a given tool from the tool-to-number mapping.
    If the tool has an associated number, it clears the assigned number and updates the UI.

    @function RemoveNumberFromTool
    @param Tool The tool from which to remove the associated number.
    @within BackpackController
]]
function BackpackController:RemoveNumberFromTool(Tool)
    local number = toolToNumber[Tool]
    if number then
        assignedNumbers[number] = nil
        toolToNumber[Tool] = nil
        self:ClearUIButton(number, Tool)
    end
end

--[[
    Updates the UI button in the backpack with the given tool and number.
    Finds the corresponding button in the player's backpack UI, sets its name to the tool's name,
    creates a viewport frame to display the tool, and adjusts the camera to fit the tool model.

    @function UpdateUIButton
    @param Tool Instance -- The tool instance to display in the backpack UI.
    @param number number -- The slot number in the backpack UI to update.
    @within BackpackController
]]
function BackpackController:UpdateUIButton(Tool, number)
    local Button = PlayerGui:WaitForChild("Backpack").Frame[tostring(number)]:FindFirstChildOfClass("ImageButton")
    if Button then
        Button.Name = Tool.Name

        local ViewportFrame = Button.Parent.ViewportFrame
        local Camera = Instance.new("Camera")
        Camera.Parent = ViewportFrame
        Camera.FieldOfView = -50

        local ViewportModel = Knit.Static.ViewportModels:FindFirstChild(Tool.Name):Clone()
        ViewportModel.Parent = ViewportFrame
        ViewportFrame.CurrentCamera = Camera

        local PlayerViewport = ViewportManager.new(ViewportFrame, Camera)
        PlayerViewport:Calibrate()

        local CF, Size = ViewportModel:GetBoundingBox()
        PlayerViewport:SetModel(ViewportModel)
        Camera.CFrame = PlayerViewport:GetMinimumFitCFrame(CFrame.new()) * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(15))
    end
end

--[[
    Clears the UI button in the backpack interface.
    This function clears the name of the button and removes any associated tool model and camera from the viewport frame.

    @function ClearUIButton
    @param number number -- The index of the button to clear.
    @param Tool Tool -- The tool associated with the button (optional).
    @within BackpackController
]]
function BackpackController:ClearUIButton(number, Tool)
    local Button = PlayerGui:WaitForChild("Backpack").Frame[tostring(number)]:FindFirstChildOfClass("ImageButton")
    if Button then
        Button.Name = ""
        if Tool then
            local Model = Button.Parent.ViewportFrame:FindFirstChild(Tool.Name)
            if Model then
                Model:Destroy()
            end
        end
        local Camera = Button.Parent.ViewportFrame:FindFirstChildOfClass("Camera")
        if Camera then
            Camera:Destroy()
        end
    end
end

--[[
    Handles the event when a tool is added to the backpack.
    Assigns a unique number to the newly added tool.

    @function OnToolAdded
    @param Tool The tool that was added to the backpack.
    @within BackpackController
]]
function BackpackController:OnToolAdded(Tool)
    self:AssignNumberToTool(Tool)
end

--[[
    Handles the removal of a tool from the player's backpack.
    Checks if the tool is still present in the character's model, and if not, removes the associated number from the tool.

    @function OnToolRemoved
    @param Tool The tool instance that was removed.
    @within BackpackController
]]
function BackpackController:OnToolRemoved(Tool)
    local Character = Player.Character or Player.CharacterAdded:Wait()

    if not Character:FindFirstChild(Tool.Name) then
        self:RemoveNumberFromTool(Tool)
    end
end

--[[
    Clears the inventory by iterating through the slots and removing the tools assigned to each slot.
    It also clears the UI button associated with each slot and resets the assigned numbers and tool-to-number mappings.

    @function ClearInventory
    @within BackpackController
]]
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

--[[
    Updates the UI for the backpack.
    Iterates through the assigned numbers and updates the corresponding UI button for each tool.

    @function UpdateUI
    @within BackpackController
]]
function BackpackController:UpdateUI()
    for number, tool in pairs(assignedNumbers) do
        self:UpdateUIButton(tool, number)
    end
end

--[[
    Initializes the backpack UI.
    Iterates through all descendants of the Backpack frame in the PlayerGui, and for each ImageButton found, connects mouse enter, mouse leave, and mouse button down events to functions that play a hover sound, animate the button size, and register button clicks.

    @function InitializeBackpackUI
    @within BackpackController
]]
function BackpackController:InitializeBackpackUI()
    for _, Button in pairs(PlayerGui:WaitForChild("Backpack").Frame:GetDescendants()) do
        if Button:IsA("ImageButton") then

            Button.MouseEnter:Connect(function()
                UIHover:Play()
                spr.target(Button.Parent, 0.8, 4, { Size = UDim2.fromScale(0.7, 1.3) })
            end)

            Button.MouseLeave:Connect(function()
                if self.ActiveTool ~= Button.Parent.Name then
                    spr.target(Button.Parent, 0.8, 4, { Size = UDim2.fromScale(0.35, 1) })  
                end
            end)

            Button.MouseButton1Down:Connect(function()
                self:RegisterButtonClick(Button)
            end)
        end
    end
end

--[[
    Resets the connections for the player's backpack.
    Connects the ChildAdded and ChildRemoved events of the player's backpack to handle tools being added or removed.

    @function ResetConnections
    @within BackpackController
]]
function BackpackController:ResetConnections()
    Player.Backpack.ChildAdded:Connect(function(Tool)
        self:OnToolAdded(Tool)
    end)

    Player.Backpack.ChildRemoved:Connect(function(Tool)
        self:OnToolRemoved(Tool)
    end)
end

--[[
    Initializes the BackpackController when Knit starts.
    Disables the default Roblox backpack UI, initializes the custom backpack UI, clears the inventory, and resets connections.
    Connects input events to handle key presses and sets up the backpack tools when the player's character is added.

    @function KnitStart
    @within BackpackController
]]
function BackpackController:KnitStart()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

    self:InitializeBackpackUI()
    self:ClearInventory()
    self:ResetConnections()

    UserInputService.InputBegan:Connect(function(Input)
        self:OnKeyPress(Input)
    end)

    if #Player.Backpack:GetChildren() > 0 then
        for _, Tool in pairs(Player.Backpack:GetChildren()) do
            self:OnToolAdded(Tool)
        end
    end

    Player.CharacterAdded:Connect(function()
        self:InitializeBackpackUI()
        self:ClearInventory()
        self:ResetConnections()

        if #Player.Backpack:GetChildren() > 0 then
            for _, Tool in pairs(Player.Backpack:GetChildren()) do
                self:OnToolAdded(Tool)
            end
        end
    end)
end

-- ————————— 🂡 —————————
-- Return Controller to Knit.
return BackpackController
