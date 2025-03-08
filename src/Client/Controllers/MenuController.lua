--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)

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

local Selected = 'rbxassetid://18833825751'
local Deselected = 'rbxassetid://18833825751'

-- Client Functions
function MenuController:KnitStart()
    UIController = Knit.GetController("UIController")

    for _, button in pairs(Buttons.List:GetChildren()) do
        if button:IsA("ImageButton") then
            button.MouseButton1Click:Connect(function()
                self:SetState(button, true)
                self:OpenPage(Pages[button.Name])
            end)
        end
    end

    MenuUI.Close.MouseButton1Click:Connect(function()
        UIController:Close(MenuUI)
    end)
    
    MenuUI:GetPropertyChangedSignal("Visible"):Connect(function()
        if not MenuUI.Visible then
            self:SetState(Buttons.List.Beverages, true)
            self:OpenPage(Pages.Beverages)
        end
    end)
end

function MenuController:SetState(Button: ImageButton, State: boolean)
    assert(Button:IsA("ImageButton"), "Button must be an ImageButton")
    assert(type(State) == "boolean", "State must be a boolean")
    

    if State then
        for _, button in pairs(Buttons.List:GetChildren()) do
            if button:IsA("ImageButton") then
                if button ~= Button then
                    button.ImageTransparency = 1
                    button.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
                Button.ImageTransparency = 0
                Button.TextLabel.TextColor3 = Color3.fromRGB(30, 30, 30)
            end
        end
    end
end

function MenuController:OpenPage(Page: ScrollingFrame)
    assert(Page:IsA("ScrollingFrame"), "Page must be a Frame")

    for _, page in pairs(Pages:GetChildren()) do
        if page:IsA("ScrollingFrame") then
            page.Visible = false
        end
    end
    Page.Visible = true
end

 -- Return Controller to Knit.
return MenuController
