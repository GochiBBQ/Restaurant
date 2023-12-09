local UserInputService = game:GetService("UserInputService")
--[[

                    __            __    __    _                __          
   ____  ____  ____/ /___  __  __/ /_  / /_  (_)___  _________/ /___ _____ 
  / __ \/ __ \/ __  / __ \/ / / / __ \/ __/ / / __ \/ ___/ __  / __ `/ __ \
 / / / / /_/ / /_/ / /_/ / /_/ / /_/ / /_  / / /_/ / /  / /_/ / /_/ / / / /
/_/ /_/\____/\__,_/\____/\__,_/_.___/\__/_/ /\____/_/   \__,_/\__,_/_/ /_/ 
                                       /___/                               


Author: nodoubtjordan
For: Gochí Restaurant 🥩
https://www.roblox.com/groups/5874921/Goch#!/about

]]

-- ————————— ↢ ⭐️ ↣ —————————
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local PlayerService = game:GetService("Players")

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables
local ViewportEffects = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Viewport"))
local spr = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("spr"))
local Knit = require(ReplicatedStorage.Packages.Knit)

local InventoryController = Knit.CreateController {
	Name = "InventoryController",
}

local LocalPlayer = PlayerService.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local UIController
local BackpackUI

local ActiveTool = nil

local inputKeys = {
	["One"] = "1",
    ["Two"] = "2",
    ["Three"] = "3",
    ["Four"] = "4",
    ["Five"] = "5",
    ["Six"] = "6",
    ["Seven"] = "7",
    ["Eight"] = "8",
    ["Nine"] = "9"
}

-- ————————— ↢ ⭐️ ↣ —————————
-- Code
function InventoryController:EquipItem(Item: Tool)
	local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local Humanoid = Character:FindFirstChild("Humanoid")

	if Item then
		if Item.Parent ~= Character then
			Humanoid:EquipTool(Item)
		end
	end
end

function InventoryController:UnequipTools()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local Humanoid = Character:FindFirstChild("Humanoid")
    Humanoid:UnequipTools()
end

function InventoryController:OnKeyPress(Input: InputObject)
    local Keybind = Input.KeyCode.Name
    local KeyValue = inputKeys[Keybind]

    if KeyValue and not UserInputService:GetFocusedTextBox() then
        local Frame = BackpackUI.Frame[KeyValue]
        self:RegisterButtonClick(Frame:FindFirstChildOfClass("TextButton"))
    end
end

function InventoryController:RegisterButtonClick(Button: GuiButton)
    for Index, ExcessFrames in pairs(BackpackUI.Frame:GetChildren()) do
        if ExcessFrames.Name ~= Button.Parent.Name and ExcessFrames:IsA("Frame") then
            spr.target(ExcessFrames, 0.8, 4, { Size = UDim2.fromScale(0.1, 0.8)})
            spr.target(ExcessFrames.Hint, 0.8, 4, { TextTransparency = 1})
            self:UnequipTools()
        end
    end

    if ActiveTool ~= Button.Parent.Name then
        spr.target(Button.Parent, 0.8, 4, { Size = UDim2.fromScale(0.35, 1)})
        spr.target(Button.Parent.Hint, 0.8, 4, { TextTransparency = 0})
        Button.Parent.Hint.Text = Button.Name
        self:EquipItem(Backpack:FindFirstChild(Button.Name))
        ActiveTool= Button.Parent.Name
    else
        spr.target(Button.Parent, 0.8, 4, { Size = UDim2.fromScale(0.1, 0.8)})
        spr.target(Button.Parent.Hint, 0.8, 4, { TextTransparency = 1})
        self:UnequipTools()
        ActiveTool = nil
    end
end

function InventoryController:KnitStart()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	UIController = Knit.GetController("UIController")
	BackpackUI = UIController.Backpack

	for Index, Buttons in pairs(BackpackUI.Frame:GetDescendants()) do
		if Buttons:IsA("TextButton") then
			Buttons.MouseButton1Click:Connect(function()
                self:RegisterButtonClick(Buttons)
			end)

            Buttons.MouseEnter:Connect(function()
                if ActiveTool ~= Buttons.Parent.Name then
                    Buttons.Parent.Hint.Text = Buttons.Name
                    spr.target(Buttons.Parent.Hint, 0.8, 4, { TextTransparency = 0})
                end
            end)

            Buttons.MouseLeave:Connect(function()
                if ActiveTool ~= Buttons.Parent.Name then
                    spr.target(Buttons.Parent.Hint, 0.8, 4, { TextTransparency = 1})
                end
            end)

            -- viewport test
            local ViewportFrame = Buttons.Parent.ViewportFrame
            local Camera = Instance.new("Camera")
            Camera.Parent = ViewportFrame
            Camera.FieldOfView = -50

            local ViewportModel = Knit.Static.ViewportModels:FindFirstChild(Buttons.Name):Clone()
            ViewportModel.Parent = ViewportFrame
            ViewportFrame.CurrentCamera = Camera

            local PlayerViewport = ViewportEffects.new(ViewportFrame, Camera)
            PlayerViewport:Calibrate()
    
            local CF, Size = ViewportModel:GetBoundingBox()
            PlayerViewport:SetModel(ViewportModel)
            Camera.CFrame = PlayerViewport:GetMinimumFitCFrame(CFrame.new()) * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(15))
		end
	end

	LocalPlayer.CharacterAdded:Connect(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end)

    UserInputService.InputBegan:Connect(function(Input)
        self:OnKeyPress(Input)
    end)
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return everything to Knit
return InventoryController