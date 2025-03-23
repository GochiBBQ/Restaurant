--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove) --- @module Trove

-- Create Knit Controller
local MenuController = Knit.CreateController {
    Name = "MenuController",
}

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI = PlayerGui:WaitForChild("GochiUI")
local MenuUI = GochiUI:WaitForChild("Menu")

local Buttons = MenuUI.Buttons
local Pages = MenuUI.Pages

local UIController

-- Client Functions
function MenuController:KnitStart()
    self._trove = Trove.new()
    UIController = Knit.GetController("UIController")

    for _, button in ipairs(Buttons.List:GetChildren()) do
        if button:IsA("ImageButton") then
            self._trove:Connect(button.MouseButton1Click, function()
                self:SetState(button)
                self:OpenPage(Pages[button.Name])
            end)
        end
    end

    self._trove:Connect(MenuUI.Close.MouseButton1Click, function()
        UIController:Close(MenuUI)
    end)

    self._trove:Connect(MenuUI:GetPropertyChangedSignal("Visible"), function()
        if not MenuUI.Visible then
            self:SetState(Buttons.List.Beverages)
            self:OpenPage(Pages.Beverages)
        end
    end)
end

function MenuController:SetState(selectedButton: ImageButton)
    for _, button in ipairs(Buttons.List:GetChildren()) do
        if button:IsA("ImageButton") then
            local isSelected = button == selectedButton
            button.ImageTransparency = isSelected and 0 or 1
            button.TextLabel.TextColor3 = isSelected
                and Color3.fromRGB(30, 30, 30)
                or Color3.fromRGB(255, 255, 255)
        end
    end
end

function MenuController:OpenPage(pageToShow: ScrollingFrame | Frame)
    for _, page in ipairs(Pages:GetChildren()) do
        if page:IsA("ScrollingFrame") or page:IsA("Frame") then
            page.Visible = page == pageToShow
        end
    end
end

function MenuController:Cleanup()
    if self._trove then
        self._trove:Destroy()
        self._trove = nil
    end
end

-- Return Controller to Knit.
return MenuController
