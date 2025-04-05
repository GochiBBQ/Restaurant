--[[

█▀▀▄ █▀▀█ █▀▀▄ █▀▀█ █░░█ █▀▀▄ ▀▀█▀▀ ▀▀█ █▀▀█ █▀▀ █░█
█░░█ █░░█ █░░█ █░░█ █░░█ █▀▀▄ ░░█░░ ▄▀░ █▄▄█ █░░ █▀▄
▀░░▀ ▀▀▀▀ ▀▀▀░ ▀▀▀▀ ░▀▀▀ ▀▀▀░ ░░▀░░ ▀▀▀ ▀░░▀ ▀▀▀ ▀░▀

Author: nodoubtzack
For: Gochí Restaurant 🥩
https://www.roblox.com/groups/5874921/Goch#!/about

]]

-- ————————— 🂡 —————————
-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService = game:GetService('UserInputService')
local PlayerService = game:GetService('Players')
local StarterGui = game:GetService('StarterGui')

-- ————————— 🂡 —————————
-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local ViewportManager = require(Knit.Modules.ViewportManager)
local spr = require(Knit.Modules.spr)

-- ————————— 🂡 —————————
-- Variables
local UIController = nil
local LocalPlayer = PlayerService.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")

-- ————————— 🂡 —————————
-- Create Knit Controller
local CustomInventoryController = Knit.CreateController {
    Name = "CustomInventoryController",
    InputKeys = {"One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten"},
}

-- ————————— 🂡 —————————
-- Client Functions
function CustomInventoryController:EquipItem(Tool: Tool)
    local Character: Instance = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid: Part = Character:FindFirstChild("Humanoid")

    if (Tool and Humanoid) and Tool.Parent ~= Character then
        Humanoid:EquipTool(Tool)
    end
end

function CustomInventoryController:UnequipItem()
    local Character: Instance = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid: Part = Character:FindFirstChild("Humanoid")

    Humanoid:UnequipTools()
end

function CustomInventoryController:OnKeyPress(Input: InputObject)
    local KeyBind: string = Input.KeyCode.Name
    local KeyValue: string = self.InputKeys[KeyBind]

    if KeyValue and not UserInputService:GetFocusedTextBox() then
        local Frame: Frame = self.BackpackUI.Frame[KeyBind]
        local TextButton: TextButton = Frame:FindFirstChildOfClass("TextButton")

        if TextButton then self:RegisterButtonClick(TextButton) end
    end
end

function CustomInventoryController:RegisterButtonClick(Button: TextButton)
    for Index, ExcessFrames in pairs(self.BackpackUI.Frame:GetChildren()) do
        if ExcessFrames.Name ~= Button.Parent.Name and ExcessFrames:IsA("Frame") then
            spr.target(ExcessFrames, 0.8, 4, { Size = UDim2.fromScale(0.1, 0.8)})
            self:UnequipItem()
        end
    end

    if self.ActiveTool ~= Button.Parent.Name then
        spr.target(Button.Parent, 0.8, 4, { Size = UDim2.fromScale(0.35, 1)})
        self:EquipItem(Backpack:FindFirstChild(Button.Name))
        self.ActiveTool = Button.Parent.Name
    else
        spr.target(Button.Parent, 0.8, 4, { Size = UDim2.fromScale(0.1, 0.8)})
        self:UnequipItem()
        self.ActiveTool = nil
    end
end

function CustomInventoryController:KnitStart()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	UIController = Knit.GetController("UIController")
	self.BackpackUI = UIController.Backpack

    for Index, Buttons in pairs(self.BackpackUI.Frame:GetDescendants()) do
		if Buttons:IsA("TextButton") then
			Buttons.MouseButton1Click:Connect(function()
                self:RegisterButtonClick(Buttons)
			end)

            -- viewport test
            local ViewportFrame = Buttons.Parent.ViewportFrame
            local Camera = Instance.new("Camera")
            Camera.Parent = ViewportFrame
            Camera.FieldOfView = -50

            local ViewportModel = Knit.Static.ViewportModels:FindFirstChild(Buttons.Name):Clone()
            ViewportModel.Parent = ViewportFrame
            ViewportFrame.CurrentCamera = Camera

            local PlayerViewport = ViewportManager.new(ViewportFrame, Camera)
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

-- ————————— 🂡 —————————
 -- Return Controller to Knit.
return CustomInventoryController
